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
require 'lshw'
require 'tmpdir'
require 'yaml'
require 'zip'

def check_data_source?(data_source)
  !(File.file?(data_source) && File.extname(data_source) == ".zip")
end

def format_bits_value(bits_value, suffix)
  value = bits_value
  counter = 0
  while value >= 1000
    counter += 1
    value /= 1000
  end
  (value*1000).round / 1000.0
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
    "#{bits_value} #{suffix}"
  else
    "#{value} #{prefix}#{suffix}"
  end
end

TARGET_FILE = '/opt/inventory_tools/domain'
REQ_FILES = ["lshw-xml.txt", "lsblk-a-P.txt"]

begin
  dir = Dir.mktmpdir('inv_ware_')
  file_locations = {}
  REQ_FILES.each do |file|
    file_locations[file] = File.join(dir, file)
  end

  if ARGV.length() < 2
    puts "Node and data source not specified"
    exit
  end

  hash = {}
  hash['Name'] = ARGV.first
  ARGV.shift
  data_source = ARGV.first
  ARGV.shift

  # parse remaining options
  options = MainParser.parse(ARGV)

  if check_data_source?(data_source)
    puts "Error with data source #{data_source}"\
         "- must be zip file"
    exit
  end

  Zip::File.open(data_source) do |zip_file|
    zip_file.each do |entry|
      puts "Extracting #{entry.name}"
    end
    if file_locations.all? { |file, v| zip_file.glob(file).first }
      file_locations.each do |file, value|
        zip_file.glob(file).first.extract(value)
      end
    else
      puts "#{REQ_FILES.join(" & ")} files required in .zip but not found."
      exit
    end
  end

  f = File.open(file_locations['lshw-xml.txt'])
  lshw = Lshw::XML(f)
  f.close

  hash['Primary Group'] = options['pri_group']

  hash['Secondary Groups'] = options['sec_groups']

  hash['Hardware Type'] = lshw.product

  hash['System Serial Number'] = lshw.serial

  hash['BIOS Version'] = lshw.firmware.first.version

  hash['CPUs'] = {}
  lshw.cpus.each do |cpu|
    hash['CPUs'][cpu.id] = {}
    hash['CPUs'][cpu.id]['Model'] = cpu.version
    hash['CPUs'][cpu.id]['Slot'] = cpu.slot
  end

  total_memory = 0
  lshw.memory_nodes.each do |mem|
    mem.banks.each do |bank|
      total_memory += bank.size
    end
  end

  hash['Total Memory'] = total_memory

  hash['Interfaces'] = {}
  lshw.all_network_interfaces.each do |net|
    hash['Interfaces'][net.logical_name] = {}
    hash['Interfaces'][net.logical_name]['Serial'] = net.mac
    hash['Interfaces'][net.logical_name]['Capacity'] = \
      format_bits_value(net.capacity, 'bit/s')
  end

  lsblk = LsblkParser.new(file_locations['lsblk-a-P.txt'])

  hash['Disks'] = {}
  lsblk.rows.each do |row|
    if row.type == 'disk'
      hash['Disks'][row.name] = {'Size'=>row.size}
    end
  end

  if !File.directory?(File.dirname(TARGET_FILE))
    puts "Directory #{File.dirname(TARGET_FILE)} not found - please create "\
      "before contining."
    exit
  end

  if options['template']
    template = File.read(options['template'])
    eruby = Erubis::Eruby.new(template)
    # overrides existing target file
    File.open(TARGET_FILE, 'w') { |file| file.write(eruby.result(:hash=>hash)) }
  else
    # make the node's name a key for the whole hash for pretty output
    yaml_hash = { hash['Name'] => hash }
    # appends to existing target file
    File.open(TARGET_FILE, 'a') { |file| file.write(yaml_hash.to_yaml) }
  end
ensure
  FileUtils.remove_entry dir
end
