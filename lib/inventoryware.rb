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
require_relative 'utils'
require 'commander/import'
require 'erubis'
require 'ostruct'
require 'tmpdir'
require 'xmlhasher'
require 'yaml'
require 'zip'

OUTPUT_DIR = File.join(lib_dir, '../store')
YAML_DIR = File.join(OUTPUT_DIR, 'yaml')
REQ_FILES = ["lshw-xml", "lsblk-a-P"]

program :name, 'Inventoryware'
program :version, '0.0.1'
program :description, 'Parser of hardware information into unified formats.'

command :parse do |c|
  c.syntax = 'invware parse ZIP_LOCATION'
  c.description = 'Parse hardware information into yaml'
  c.action do |args, options|
    unless args.length() == 1
      puts "Error: The data source should be the only argument."
      exit
    end
    data_source = args[0]
    # confirm data exists and is in right format (.zip)
    if check_data_source?(data_source)
      puts "Error: data source #{data_source}"\
           " - must be zip file"
      exit
    end
    begin
      #create a tmp file for each required file
      dir = Dir.mktmpdir('inv_ware_')
      file_locations = {}
      REQ_FILES.each do |file|
        file_locations[file] = File.join(dir, file)
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
          puts "Error: #{REQ_FILES.join(" & ")} files required in .zip but not found."
          exit
        end
      end
      XmlHasher.configure do |config|
        config.snakecase = true
        config.ignore_namespaces = true
        config.string_keys = true
      end
      hash = {}
      # The node's name is inferred from the name of the .zip
      # The second argument removes the extension
      hash['Name'] = File.basename(data_source, ".*")
      #TODO find which format the groups will be specifed in and scrub like that
      # extract data from lshw
      hash['lshw'] = XmlHasher.parse(File.read(file_locations['lshw-xml']))
      # extract data from lsblk
      hash['lsblk'] = LsblkParser.new(file_locations['lsblk-a-P']).hashify()
      # output
      exit_unless_dir(YAML_DIR)
      yaml_out_name = "#{hash['Name']}.yaml"
      out_file = File.join(YAML_DIR, yaml_out_name)
      # This section, for adding the data to any existing yaml, has no use now
      # each node gets its own output file. I'm leaving it here in the case that
      # someone manages to rename a yaml, so it won't be overriden by new data.
      yaml_hash = {}
      if File.file?(out_file)
        begin
          yaml_hash = YAML.load_file(out_file)
        rescue Psych::SyntaxError
          # If the file is not valid yaml we delete it & keep the hash empty
          # Psych is the underlying library YAML uses
        end
      end
      yaml_hash[hash['Name']] = hash
      yaml_hash = Hash[yaml_hash.sort_by { |k,v| k }]
      File.open(out_file, 'w') { |file| file.write(yaml_hash.to_yaml) }
    ensure
      FileUtils.remove_entry dir
    end
  end
end

def gen_ctx_with_plugins(hash, template)
  render_env = Module.new do
    def hash
      hash
    end
  end
  Dir[File.join(File.dirname(__FILE__), '..', 'plugins', '*.rb')].each do |file|
    #TODO replace __FILE__
    render_env.instance_eval(File.read(file))
  end
  ctx = render_env.instance_eval { binding }
end

command :render do |c|
  c.syntax = "invware render NODE TEMPLATE [LOCATION]"
  c.description = "Render a node's data as an eRuby template"
  c.option '-l', '--location LOCATION', String, 'Destination for the filled template'
  c.action do |args, options|
    unless args.length == 2
      puts "Error: 'node' and 'template' should be the only arguments"
      exit
    end
    node = args[0]
    template = args[1]
    node_yaml = "#{node}.yaml"
    node_yaml_location = File.join(YAML_DIR, node_yaml)
    unless File.file?(node_yaml_location)
      puts "Error: #{node_yaml} file not found within #{File.expand_path(YAML_DIR)}"
      exit
    end
    begin
      hash = YAML.load_file(node_yaml_location)[node]
    rescue Psych::SyntaxError
      puts "Error: parsing yaml in #{node_yaml_location} - aborting"
      exit
    end
    # confirm file location exists
    # decided against creating location if it did not exist as it requires sudo
    #   execution - it may be that this would be better changed
    if options.location
      unless validate_file(options.location)
        puts "Error: Invalid destination '#{options.location}'"
        exit
      end
      out_file = options.location
    else
      exit_unless_dir(OUTPUT_DIR)
    end

    # output
    # TODO verfiy template?
    template_contents = File.read(template)
    eruby = Erubis::Eruby.new(template_contents)
    template_out_name = "#{node}_#{File.basename(template)}"
    out_file ||= File.join(OUTPUT_DIR, template_out_name)
    File.open(out_file, 'w') do |file|
      file.write(eruby.result(gen_ctx_with_plugins(hash, template_contents)))
    end
  end
end
