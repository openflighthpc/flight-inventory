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
        raise FileSysError, <<-ERROR
Directory #{File.expand_path(path)} not found.
Please create it before continuing."
        ERROR
      end
      return true
    end

    # given a list of nodes, expand each elem that is a range
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
      nodes.push(*new_nodes)
      return expand_asterisks(nodes)
    end

    def self.expand_asterisks(nodes)
      new_nodes = []
      nodes.each do |node|
        if node.match(/\*/)
          node_names = Dir.glob(File.join(YAML_DIR, node)).map { |file|
            File.basename(file, '.yaml')
          }
          new_nodes.push(*node_names)
        end
      end
      nodes.delete_if { |node| node.match(/\*/) }
      nodes.push(*new_nodes)
      return nodes
    end

    # Errors for each way that arguments and nodes can be given incorrectly
    # 'other_args' in an array of all non-node arguments for the command
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


    def self.find_file(search_val, &glob)
      results = yield(search_val)
        if results.empty?
          puts "No files found for '#{search_val}'"
          return nil
        elsif results.length > 1
          puts "Ambiguous search term '#{search_val}' - possible results are:"
          results.map! { |p| File.basename(p, File.extname(p)) }
          results.each_slice(3).each { |p| puts p.join("  ") }
          puts "Please refine your search"
          return nil
        else
          return results[0]
        end
    end

    # returns the yaml hash of a file at the given location
    def self.read_node_yaml(node_location)
      node_data = nil
      begin
        File.open(node_location) do |f|
          node_data = YAML.safe_load(f)
        end
      rescue Psych::SyntaxError
        raise ParseError, <<-ERROR
Error parsing yaml in #{node_location} - aborting
        ERROR
      end
      # condition for if the .yaml is empty
      unless node_data
        raise ParseError, <<-ERROR
Yaml in #{node_location} is empty - aborting
        ERROR
      end
      return node_data.values[0]
    end

    # outputs the node data to the specified location
    def self.output_node_yaml(node_data, location)
      unless check_file_writable?(location)
        raise FileSysError, <<-ERROR
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

    # given a set of nodes and relevant options returns an expanded list
    #   of all the necessary nodes
    def self.select_nodes(nodes, options, return_missing = false)
      node_locations = []
      if options.all
        node_locations = find_all_nodes
      else
        if nodes
          node_locations.push(*find_nodes(nodes, return_missing))
        end
        if options.group
          node_locations.push(*find_nodes_in_groups(options.group.split(',')))
        end
      end
      #TODO move uniq & sorting here?
      return node_locations
    end

    private
    # retrieves all .yaml files in the storage dir
    def self.find_all_nodes()
      node_locations = Dir.glob(File.join(YAML_DIR, '*.yaml'))
      if node_locations.empty?
        $stderr.puts "No node data found in #{File.expand_path(YAML_DIR)}"
      end
      return node_locations
    end

    # retreives all nodes in the given groups
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
          m = contents.match(/primary_group: (.*?)$/)
          found.append(m[1]) if m
          m = contents.match(/secondary_groups: (.*?)$/)
          found = found + (m[1].split(',')) if m
        end
        unless (found & groups).empty?
          nodes.append(location)
        end
      end
      if nodes.empty?
        $stderr.puts "No nodes found in #{groups.join(' or ')}."
      end
      return nodes
    end

    # retreives the .yaml file for each of the given nodes
    # expands node ranges if they exist
    # if return missing is passed, returns paths to the .yamls of non-existent
    #   nodes
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
            $stderr.puts "Skipping."
            next
          end
        end
        node_locations.append(node_yaml_location)
      end
      return node_locations
    end
  end
end
