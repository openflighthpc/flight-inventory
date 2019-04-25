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
        nodes = node_paths.map { |p| Node.new(p) }
        nodes.each { |n| n.check_schema }
        return nodes
      end

      # retreives all nodes in the given groups
      # note: if speed becomes an issue this should be reverted back to the old
      # method of converting the yaml to a string and searching with regex
      def find_nodes_in_groups(groups, node_list = find_all_nodes())
        groups = *groups unless groups.is_a?(Array)
        nodes = []
        node_list.each do |node|
          found = []
          found = found << node.primary_group if node.primary_group
          found = found + node.secondary_groups if node.secondary_groups
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
      if @data
        type = @data['type']
      else
        type = nil
        IO.foreach(@path) do | line|
          if m = line.match(/^type: (.*)$/)
            type = m[1]
            break
          end
        end
      end
      type = 'server' unless type
      return type
    end

    def schema
      if @data
        schema = @data['schema']
      else
        schema = nil
        IO.foreach(@path) do | line|
          if m = line.match(/^schema: (.*)$/)
            schema = m[1]
            break
          end
        end
      end
      schema = 0 unless schema
      return schema
    end


    def primary_group
      return @data.dig('mutable','primary_group') if @data
      pri_group = nil
      IO.foreach(@path) do | line|
        if m = line.match(/^  primary_group: (.*)$/)
          pri_group = m[1]
          break
        end
      end
      return pri_group
    end

    def secondary_groups
      return @data.dig('mutable','secondary_groups') if @data
      sec_groups = nil
      IO.foreach(@path) do | line|
        if m = line.match(/^  secondary_groups: (.*)$/)
          sec_groups = m[1].split(',')
          break
        end
      end
      return sec_groups
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
      @data = node_data
      return @data
    end

    def save
      # this `.data` call is necessary to prevent attempting to write nothing
      # to the file
      self.data
      unless Utils.check_file_writable?(@path)
        raise FileSysError, <<-ERROR.chomp
Output file #{@path} not accessible - aborting
        ERROR
      end
      File.open(@path, 'w') { |file| file.write(data.to_yaml) }
    end

    def create_if_non_existent(type = '')
      unless Utils.check_file_readable?(@path)
        @data = {
          'name' => @name,
          'mutable' => {},
          'type' => type,
          'schema' => SCHEMA_NUM,
        }
        save
      end
    end

    def check_schema
      unless schema.to_f >= REQ_SCHEMA_NUM
        raise FileSysError, <<-ERROR.chomp
Asset '#{name}' has data in the wrong schema
Please update it before continuing
(Has #{schema}; minimum required is #{REQ_SCHEMA_NUM})
        ERROR
      end
    end

    attr_reader :path, :name
  end
end
