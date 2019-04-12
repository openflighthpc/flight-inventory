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
        node_paths = Dir.glob(File.join(Config.yaml_dir, '*.yaml'))
        if node_paths.empty?
          $stderr.puts "No asset data found "\
            "in #{File.expand_path(Config.yaml_dir)}"
        end
        return node_paths.map { |p| Node.new(p) }
      end

      # retreives all nodes in the given groups
      # note: if speed becomes an issue this should be reverted back to the old
      # method of converting the yaml to a string and searching with regex
      def find_nodes_in_groups(groups, node_list = find_all_nodes())
        keys = ['primary_group', 'secondary_groups']
        groups = *groups unless groups.is_a?(Array)
        nodes = []
        node_list.each do |node|
          found = []
          mutable = node.data['mutable']
          keys.each do |key|
            found = found + mutable[key].split(',') if mutable.key?(key)
          end
          unless (found & groups).empty?
            nodes.append(node)
          end
        end
        if nodes.empty?
          $stderr.puts "No assets found in #{groups.join(' or ')}."
        end
        return nodes
      end

      # retreives all nodes with the given type
      # This cannot easily be done by converting the yaml to a string and
      # searching with regex as the `lshw` hash has keys called 'type'
      def find_nodes_with_types(target_types, node_list = find_all_nodes())
        key = ['type']
        target_types = *target_types unless target_types.is_a?(Array)
        target_types.map! { |t| t.downcase }
        nodes = []
        node_list.each do |node|
          if target_types.include?(node.type.downcase)
            nodes.append(node)
          end
        end
        if nodes.empty?
          $stderr.puts "No assets found with type #{target_types.join(' or ')}."
        end
        return nodes
      end

      # retreives the .yaml file for each of the given nodes
      # expands node ranges if they exist
      # if return missing is passed, returns paths to the .yamls of non-existent
      #   nodes
      def find_single_nodes(node_str, return_missing = false)
        node_names = expand_asterisks(NodeattrUtils::NodeParser.expand(node_str))
        $stderr.puts "No assets found for '#{node_str}'" if node_names.empty?

        type = nil
        nodes = []
        node_names.each do |node_name|
          node_yaml = "#{node_name}.yaml"
          node_yaml_location = File.join(Config.yaml_dir, node_yaml)
          unless Utils.check_file_readable?(node_yaml_location)
            $stderr.puts "File #{node_yaml} not found within "\
              "#{File.expand_path(Config.yaml_dir)}"
            if return_missing
              $stderr.puts "Creating..."
              type = type || Utils.get_new_asset_type
            else
              $stderr.puts "Skipping."
              next
            end
          end
          node = Node.new(node_yaml_location)
          node.create_if_non_existent(type)
          nodes.append(node)
        end
        return nodes
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

      def make_unique(nodes)
        nodes.uniq { |n| [n.path] }
      end
    end

    def initialize(path)
      @path = path
      @name = File.basename(path, File.extname(path))
    end

    def data
      @data ||= open
    end

    def type
      # hack-y method to save time - rather than load the node's data into mem
      #   as a hash if the data isn't going to be used for anything, just grep.
      #   This time saving add up if listing 100s of nodes
      # TODO UPDATE THIS WHEN THE YAML FORMAT IS CHANGED (issue #119)
      #   this will alter the amount of whitespace prepending 'type' and as such
      #   the regex will need to be changed
      return @data['type'] if @data
      type = nil
      IO.foreach(@path) do | line|
        if m = line.match(/^  type: (.*)$/)
          type = m[1]
          break
        end
      end
      # return nil if not found (instead of erroring) to match the
      # output of using `@data['type']
      return type
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
