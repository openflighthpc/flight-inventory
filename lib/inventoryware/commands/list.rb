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
require 'inventoryware/command'
require 'inventoryware/config'
require 'inventoryware/node'

module Inventoryware
  module Commands
    class List < Command
      def run
        # note: this process has become quite time intensive when options are
        # passed - taking suggestions on speeding it up

        nodes = if not @options.group and not @options.type
                  attr = 'type'
                  Node.find_all_nodes
                else
                  all_nodes = Node.find_all_nodes
                  if @options.group
                    attr = 'primary_group'
                    filter_nodes(all_nodes, @options.group, 'find_nodes_in_groups')
                  elsif @options.type
                    attr = 'type'
                    filter_nodes(all_nodes, @options.type, 'find_nodes_with_types')
                  end
                end

        unless nodes.empty?
          hash = create_hash_of_attribute(nodes, attr)
          hash.each do |k,v|
            puts "\n##{k.upcase}"
            puts v.sort
          end
        else
          return if @options.group or @options.type
          $stderr.puts "No asset files found within #{File.expand_path(Config.yaml_dir)}"
        end
      end

      private


      def create_hash_of_attribute(nodes, attr)
        hash = {}
        nodes.each do |node|
          key = node.public_send(attr)
          hash[key] = [] unless hash.key?(key)
          hash[key] << node.name
        end
        return hash.sort.to_h
      end

      def filter_nodes(nodes, options, search_method)
        unless options == true
          found = []

          filter = options.split(',')
          found.concat(Node.public_send(search_method, filter, nodes))

          Node.make_unique(found)
        else
          nodes
        end
      end
    end
  end
end
