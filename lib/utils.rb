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

    def self.exit_unless_dir(path)
      unless File.directory?(path)
        raise FileSysError, <<-ERROR
Directory #{File.expand_path(path)} not found.
Please create it before continuing."
        ERROR
      end
      return true
    end

    def self.expand_node_ranges(nodes)
      new_nodes = []
      nodes.each do |node|
        if node.match(/.*\[[0-9]+.*[0-9]+\]$/)
          m = node.match(/^(.*)\[(.*)\]$/)
          prefix = m[1]
          suffix = m[2]
          ranges = suffix.split(',')
          ranges.each do |range|
            if range.match(/-/)
              num_1, num_2 = range.split('-')
              (num_1.to_i .. num_2.to_i).each do |num|
                new_nodes << "#{prefix}#{num.to_s.rjust(num_1.length, '0')}"
              end
            else
              new_nodes << "#{prefix}#{range}"
            end
          end
          nodes.delete(node)
        end
      end
      nodes = nodes + new_nodes
      return nodes
    end

    #TODO make this method less awful
    def self.resolve_node_options(argv, options, other_args)
      arg_str = other_args.join(', ')

      if options.all
        unless argv.length == other_args.length
          unless other_args.length == 0
            raise ArgumentError, <<-ERROR
#{arg_str} should be the only argument(s) - all nodes are being parsed.
            ERROR
          else
            raise ArgumentError, <<-ERROR
There should be the no arguments - all nodes are being parsed.
            ERROR
          end
        end

      elsif options.group
        if argv.length < other_args.length
          raise ArgumentError, <<-ERROR
Please provide #{arg_str}.
          ERROR
        end

      else
        if argv.length < other_args.length + 1
          unless other_args.length == 0
            raise ArgumentError, <<-ERROR
Please provide #{arg_str} and at least one node.
            ERROR
          else
            raise ArgumentError, <<-ERROR
Please provide at least one node.
            ERROR
          end
        end
      end

      nodes = argv[other_args.length..-1]
    end

    def self.read_node_yaml(node_location)
      begin
        node_data = YAML.load_file(node_location)
      rescue Psych::SyntaxError
        raise InventorywareError <<-ERROR
Error parsing yaml in #{node_location} - aborting
        ERROR
      end
      return node_data
    end

    def self.output_node_yaml(node_data, location)
      unless check_file_writable?(location)
        raise FileSysError, <<-ERROR
Output file #{location} not accessible - aborting
        ERROR
      end
      yaml_hash = {node_data['name'] => node_data}
      File.open(location, 'w') { |file| file.write(yaml_hash.to_yaml) }
    end

    def self.read_node_or_create(location)
      if Utils::check_file_readable?(location)
        node_data = Utils.read_node_yaml(location).values[0]
      else
        node_data = {
          'name' => File.basename(location, '.yaml'),
          'mutable' => {},
          'imported' => false
        }
      end
      return node_data
    end

    def self.select_nodes(nodes, options, return_missing = false)
      node_locations = []
      if options.all
        node_locations = find_all_nodes
      else
        if nodes
          node_locations.push(*find_nodes(nodes, return_missing = true))
        end
        if options.group
          node_locations.push(*find_nodes_in_groups(options.group.split(',')))
        end
      end
      return node_locations
    end

    private
    def self.find_all_nodes()
      node_locations = Dir.glob(File.join(YAML_DIR, '*.yaml'))
      if node_locations.empty?
        raise FileSysError, <<-ERROR
No node data found in #{File.expand_path(YAML_DIR)}
        ERROR
      end
      return node_locations
    end

    # this quite an intensive method of way to go about searching the yaml
    # each file is converted to a sting and then searched
    # seems fine as it stands but if speed becomes an issue could stand to
    #   be changed
    def self.find_nodes_in_groups(groups)
      nodes = []
      find_all_nodes().each do |location|
        found = []
        File.open(location) do |file|
          contents = file.read
          m = contents.match(/primary_group: (.*?)$/)[1]
          found.append(m) unless m.empty?
          m = contents.match(/secondary_groups: (.*?)$/)[1]
          found = found + (m.split(',')) unless m.empty?
        end
        unless (found & groups).empty?
          nodes.append(location)
        end
      end
      if nodes.empty?
        $stderr.puts "No nodes found in #{groups.join(', ')}."
      end
      return nodes
    end

    def self.find_nodes(nodes, return_missing = false)
      nodes = expand_node_ranges(nodes)
      node_locations = []
      nodes.each do |node|
        node_yaml = "#{node}.yaml"
        node_yaml_location = File.join(YAML_DIR, node_yaml)
        unless check_file_readable?(node_yaml_location)
          $stderr.puts "File #{node_yaml} not found within "\
            "#{File.expand_path(YAML_DIR)}"
          if return_missing
            $stderr.puts "Creating..."
          else
            $stderr.puts "Skipping"
            next
          end
        end
        node_locations.append(node_yaml_location)
      end
      return node_locations
    end
  end
end
