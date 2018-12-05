#!/usr/bin/env ruby
#==============================================================================
# Copyright (C) 2018 Stephen F. Norledge and Alces Software Ltd.
#
# This file/package is part of Alces inventoryware.
#
# Alces inventoryware is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# Alces inventoryware is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this package.  If not, see <http://www.gnu.org/licenses/>.
#
# For more information on Alces inventoryware, please visit:
# https://github.com/alces-software/inventoryware
#==============================================================================

lib_dir = File.dirname(__FILE__)
ENV['BUNDLE_GEMFILE'] ||= File.join(lib_dir, '..', 'Gemfile')

require 'rubygems'
require 'bundler'

if ENV['INVWARE_DEBUG']
  Bundler.setup(:default, :development)
  require 'pry-byebug'
else
  Bundler.setup(:default)
end

require_relative 'cli'
require_relative 'lsblk_parser'
require 'erubis'
require 'tmpdir'
require 'xmlhasher'
require 'yaml'
require 'zip'

def check_data_source?(data_source)
  !(File.file?(data_source) && File.extname(data_source) == ".zip")
end

# convert decimal amount of bits to a human readable format
def format_bits_value(bits_value)
  format_data_value(bits_value, 1000, 'bit/s')
end

# convert binary amount of bytes to a human readable format
def format_bytes_value(bytes_value)
  format_data_value(bytes_value, 1024, 'iB')
end

def format_data_value(orig_value, grouping, suffix)
  value = orig_value
  counter = 0
  while value >= grouping
    counter += 1
    value /= grouping
  end
  (value*grouping).round / grouping.to_f
  case counter
  when 0
    prefix = ''
  when 1
    prefix = 'K'
  when 2
    prefix = 'M'
  when 3
    prefix = 'G'
  when 4
    prefix = 'T'
  when 5
    prefix = 'P'
  else
    prefix = ''
  end
  # prevent errors if the counter gets too large, return original value
  if prefix == ''
    "#{orig_value} #{suffix}"
  else
    "#{value} #{prefix}#{suffix}"
  end
end

OUTPUT_DIR = '/opt/inventoryware/output'
YAML_FILE = "#{OUTPUT_DIR}/domain"
REQ_FILES = ["lshw-xml", "lsblk-a-P"]

begin
  #create a tmp file for each required file
  dir = Dir.mktmpdir('inv_ware_')
  file_locations = {}
  REQ_FILES.each do |file|
    file_locations[file] = File.join(dir, file)
  end

  # parse remaining options
  options = MainParser.parse(ARGV)

  if ARGV.length() < 2
    puts "Node and data source not specified"
    exit
  end

  # grab first arguments
  hash = {}
  hash['Name'] = ARGV.first
  ARGV.shift
  data_source = ARGV.first
  ARGV.shift

  # confirm data exists and is in right format (.zip)
  if check_data_source?(data_source)
    puts "Error with data source #{data_source}"\
         " - must be zip file"
    exit
  end

  # unzip data and extract each required file to the created tmp files
  Zip::File.open(data_source) do |zip_file|
    zip_file.each do |entry|
      puts "Extracting #{entry.name}"
    end
    if file_locations.all? { |file, v| zip_file.glob("#{file}*").first }
      file_locations.each do |file, value|
        zip_file.glob("#{file}*").first.extract(value)
      end
    else
      puts "#{REQ_FILES.join(" & ")} files required in .zip but not found."
      exit
    end
  end

  hash['Primary Group'] = options['pri_group']

  hash['Secondary Groups'] = options['sec_groups']

  #this may need to be changed to not "slurp" the file
  hash['lshw'] = XmlHasher.parse(File.read(file_locations['lshw-xml']))

  # extract data from lsblk
  lsblk = LsblkParser.new(file_locations['lsblk-a-P'])

  hash['lsblk'] = {}
  lsblk.rows.each do |row|
    if !hash['lsblk'][row.type]
      hash['lsblk'][row.type] = {}
    end
    hash['lsblk'][row.type][row.name] = {
      'MAJ:MIN' => row.maj_min,
      'RM' => row.rm,
      'SIZE' => row.size,
      'RO' => row.ro,
      'MOUNTPOINT' => row.mountpoint
    }
  end

  # confirm file location exists
  # decided against creating location if it did not exist as it requires sudo
  #   execution - it may be that this would be better changed
  if !File.directory?(OUTPUT_DIR)
    puts "Directory #{OUTPUT_DIR} not found - please create it"\
      "before contining."
    exit
  end

  # output
  if options['template']
    template = File.read(options['template'])
    eruby = Erubis::Eruby.new(template)
    template_out_name = "#{hash['Name']}_#{File.basename(options['template'])}"
    template_out_file = "#{OUTPUT_DIR}/#{template_out_name}"
    # overrides existing target file
    File.open(template_out_file, 'w') do |file|
      file.write(eruby.result(:hash=>hash))
    end
  else
    yaml_hash = {}
    if File.file?(YAML_FILE)
      begin
        yaml_hash = YAML.load_file(YAML_FILE)
      rescue Psych::SyntaxError
        # If the file is not valid yaml we delete it & keep the hash empty
        # Psych is the underlying library YAML uses
      end
    end
    yaml_hash[hash['Name']] = hash
    yaml_hash = Hash[yaml_hash.sort_by { |k,v| k }]
    File.open(YAML_FILE, 'w') { |file| file.write(yaml_hash.to_yaml) }
  end
ensure
  FileUtils.remove_entry dir
end
