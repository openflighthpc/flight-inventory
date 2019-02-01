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

require 'nodeattr_utils'

module Inventoryware
  module Utils
    # return a single file from glob, error if >/< than 1 found
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

    # given a set of nodes and relevant options returns an expanded list
    #   of all the necessary nodes
    def self.locate_nodes(nodes, options, return_missing = false)
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
      nodes = expand_asterisks(NodeattrUtils::NodeParser.expand(nodes))
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
  end
end
