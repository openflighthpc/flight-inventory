# =============================================================================
# Copyright (C) 2019-present Alces Flight Ltd.
#
# This file is part of Flight Inventory.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# Flight Inventory is distributed in the hope that it will be useful, but
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
# IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
# OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
# PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
# details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with Flight Inventory. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on Flight Inventory, please visit:
# https://github.com/openflighthpc/flight-inventory
# ==============================================================================
require 'inventoryware/exceptions'
require 'inventoryware/utils'

module Inventoryware
  class Node
    class << self
      # retrieves all .yaml files in the storage dir
      def find_all_nodes()
        node_locations = Dir.glob(File.join(Config.yaml_dir, '*.yaml'))
        if node_locations.empty?
          $stderr.puts "No asset data found "\
            "in #{File.expand_path(Config.yaml_dir)}"
        end
        return node_locations
      end

      # retreives all nodes in the given groups
      # this quite an intensive method of way to go about searching the yaml
      # each file is converted to a sting and then searched
      # seems fine as it stands but if speed becomes an issue could stand to
      #   be changed
      def find_nodes_in_groups(groups)
        groups = *groups unless groups.is_a?(Array)
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
          $stderr.puts "No assets found in #{groups.join(' or ')}."
        end
        return nodes
      end

      # retreives the .yaml file for each of the given nodes
      # expands node ranges if they exist
      # if return missing is passed, returns paths to the .yamls of non-existent
      #   nodes
      def find_single_nodes(node_str, return_missing = false)
        nodes = expand_asterisks(NodeattrUtils::NodeParser.expand(node_str))
        $stderr.puts "No assets found for '#{node_str}'" if nodes.empty?
        node_locations = []
        nodes.each do |node|
          node_yaml = "#{node}.yaml"
          node_yaml_location = File.join(Config.yaml_dir, node_yaml)
          unless Utils.check_file_readable?(node_yaml_location)
            $stderr.puts "File #{node_yaml} not found within "\
              "#{File.expand_path(Config.yaml_dir)}"
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

      def expand_asterisks(nodes)
        new_nodes = []
        nodes.each do |node|
          if node.match(/\*/)
            node_names = Dir.glob(File.join(Config.yaml_dir, node)).map { |file|
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

    def initialize(path)
      @path = path
      @name = File.basename(path, File.extname(path))
    end

    def data
      @data ||= open
    end

    def data=(value)
      @data = value
    end

    def open
      node_data = Utils.load_yaml(@path)
      # condition for if the .yaml is empty
      unless node_data
        raise ParseError, <<-ERROR.chomp
Yaml in #{@path} is empty - aborting
        ERROR
      end
      @data = node_data.values[0]
      return @data
    end

    def save
      unless Utils.check_file_writable?(@path)
        raise FileSysError, <<-ERROR.chomp
Output file #{@path} not accessible - aborting
        ERROR
      end
      yaml_hash = {data['name'] => data}
      File.open(@path, 'w') { |file| file.write(yaml_hash.to_yaml) }
    end

    def create_if_non_existent(type = '')
      unless Utils.check_file_readable?(@path)
        @data = {
          'name' => @name,
          'mutable' => {},
          'type' => type,
        }
        save
      end
    end

    attr_reader :path, :name
  end
end
