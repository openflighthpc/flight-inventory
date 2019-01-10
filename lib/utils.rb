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
        $stderr.puts "Error: Directory #{File.expand_path(path)} not found - "\
          "please create it before continuing."
        exit
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
              padding = num_1.match(/^0+/)
              unless num_1 <= num_2
                $stderr.puts "Invalid node range #{range}"
                exit
              end
              (num_1.to_i .. num_2.to_i).each do |num|
                new_nodes.push(sprintf("%s%0#{padding.to_s.length + 1}d", prefix, num))
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

    def self.resolve_node_options(argv, options, other_args)
      arg_str = other_args.join(', ')
      if options.all
        unless argv.length == other_args.length
          $stderr.puts "Error: #{arg_str} should be the only argument(s) - all "\
            "nodes are being parsed."
          exit
        end
      elsif options.group
        if argv.length < other_args.length
          $stderr.puts "Error: please provide #{arg_str}."
          exit
        end
      elsif argv.length < other_args.length + 1
        $stderr.puts "Error: Please provide #{arg_str} and at least one "\
          "node."
        exit
      end

      nodes = argv[other_args.length..-1]
    end

    def self.read_node_yaml(node_location)
      begin
        node_data = YAML.load_file(node_location)
      rescue Psych::SyntaxError
        $stderr.puts "Error: parsing yaml in #{node_location} - aborting"
        exit
      end
      return node_data
    end

    def self.output_node_yaml(node_data, location)
      unless check_file_writable?(location)
        $stderr.puts "Error: output file #{location} not accessible "\
          "- aborting"
        exit
      end
      yaml_hash = {node_data['name'] => node_data}
      File.open(location, 'w') { |file| file.write(yaml_hash.to_yaml) }
    end

    def self.select_nodes(nodes, options)
      node_locations = []
      if options.all
        node_locations = find_all_nodes
      else
        if nodes
          node_locations.push(*find_nodes(nodes))
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
        $stderr.puts "Error: No node data found in #{YAML_DIR}"
        exit
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

    def self.find_nodes(nodes)
      nodes = expand_node_ranges(nodes)
      node_locations = []
      nodes.each do |node|
        node_yaml = "#{node}.yaml"
        node_yaml_location = File.join(YAML_DIR, node_yaml)
        unless check_file_readable?(node_yaml_location)
          $stderr.puts "File #{node_yaml} not found within "\
            "#{File.expand_path(YAML_DIR)}"
          next
        end
        node_locations.append(node_yaml_location)
      end
      return node_locations
    end
  end
end
