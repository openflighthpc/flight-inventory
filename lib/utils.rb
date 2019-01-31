#==============================================================================
# Copyright (C) 2018-19 Stephen F. Norledge and Alces Software Ltd.
#
# This file/package is part of Alces Inventoryware.
#
# Alces Inventoryware is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# Alces Inventoryware is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this package.  If not, see <http://www.gnu.org/licenses/>.
#
# For more information on Alces Inventoryware, please visit:
# https://github.com/alces-software/inventoryware
#==============================================================================

module Inventoryware
  module Utils
    def self.check_zip_exists?(path)
      (File.file?(path) && check_zip?(path))
    end

    def self.check_zip?(path)
      File.extname(path) == ".zip"
    end

    def self.check_file_writable?(path)
      return false unless check_file_location?(path)
      return false if File.exist?(path) and not File.writable?(path)
      return true
    end

    def self.check_file_readable?(path)
      return false unless check_file_location?(path)
      return false unless File.exists?(path)
      return false unless File.readable?(path)
      return true
    end

    def self.check_file_location?(path)
      return false if File.directory?(path)
      return false unless File.directory?(File.dirname(path))
      return false if File.exists?(path) and not File.readable?(path)
      return true
    end

    # raise an error if given path isn't a directory
    def self.exit_unless_dir(path)
      unless File.directory?(path)
        raise FileSysError, <<-ERROR.chomp
Directory #{File.expand_path(path)} not found.
Please create it before continuing"
        ERROR
      end
      return true
    end

    # Errors for each way that arguments and nodes can be given incorrectly
    # 'other_args' in an array of all non-node arguments for the command
    #TODO make this method less awful
    def self.resolve_node_options(argv, options, other_args)
      arg_str = other_args.join(', ')

      if options.all
        unless argv.length == other_args.length
          unless other_args.length == 0
            raise ArgumentError, <<-ERROR.chomp
#{arg_str} should be the only argument(s) - all nodes are being parsed
            ERROR
          else
            raise ArgumentError, <<-ERROR.chomp
There should be the no arguments - all nodes are being parsed
            ERROR
          end
        end

      elsif options.group
        if argv.length < other_args.length
          raise ArgumentError, <<-ERROR.chomp
Please provide #{arg_str}
          ERROR
        end

      else
        if argv.length < other_args.length + 1
          unless other_args.length == 0
            raise ArgumentError, <<-ERROR.chomp
Please provide #{arg_str} and at least one node
            ERROR
          else
            raise ArgumentError, <<-ERROR.chomp
Please provide at least one node
            ERROR
          end
        end
      end

      nodes = argv[other_args.length..-1]
    end

    # returns the yaml hash of a file at the given location
    def self.read_node_yaml(node_location)
      node_data = nil
      begin
        File.open(node_location) do |f|
          node_data = YAML.safe_load(f)
        end
      rescue Psych::SyntaxError
        raise ParseError, <<-ERROR.chomp
Error parsing yaml in #{node_location} - aborting
        ERROR
      end
      # condition for if the .yaml is empty
      unless node_data
        raise ParseError, <<-ERROR.chomp
Yaml in #{node_location} is empty - aborting
        ERROR
      end
      return node_data.values[0]
    end

    # outputs the node data to the specified location
    def self.output_node_yaml(node_data, location)
      unless check_file_writable?(location)
        raise FileSysError, <<-ERROR.chomp
Output file #{location} not accessible - aborting
        ERROR
      end
      yaml_hash = {node_data['name'] => node_data}
      File.open(location, 'w') { |file| file.write(yaml_hash.to_yaml) }
    end

    # reads a node's yaml but creats one if it doesn't exist
    def self.read_node_or_create(location)
      if Utils::check_file_readable?(location)
        node_data = Utils.read_node_yaml(location)
      else
        node_data = {
          'name' => File.basename(location, '.yaml'),
          'mutable' => {},
          'imported' => false
        }
      end
      return node_data
    end
  end
end
