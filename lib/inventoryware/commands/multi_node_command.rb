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
require 'inventoryware/exceptions'
require 'inventoryware/node'

require 'nodeattr_utils'

module Inventoryware
  module Commands
    class MultiNodeCommand < Command
      def fetch_nodes(*args)
        resolve_node_options(@argv, @options, args)

        node_names = @argv[args.length]

        nodes = find_nodes(node_names, @options)
        nodes = Node.make_unique(nodes)
        return nodes
      end

      private
      # Errors for each way that arguments and nodes can be given incorrectly
      # 'other_args' is an array of all non-node arguments for the command
      def resolve_node_options(argv, options, other_args)
        arg_str = other_args.join(', ')

        if options.all
          unless argv.length == other_args.length
            unless other_args.length == 0
              raise ArgumentError, <<-ERROR.chomp
#{arg_str} should be the only argument(s) - all assets are being parsed
              ERROR
            else
              raise ArgumentError, <<-ERROR.chomp
There should be no arguments - all assets are being parsed
              ERROR
            end
          end
        end
      end

      # given a set of nodes and relevant options returns an expanded list
      #   of all the necessary nodes
      def find_nodes(node_names, options)
        nodes = []
        if options.all
          nodes = Node.find_all_nodes
        else
          if node_names
            nodes.push(*Node.find_single_nodes(node_names, !!options.create))
          end
          if options.group
            nodes.push(*Node.find_nodes_in_groups(options.group.split(',')))
          end
        end
        if nodes.empty?
          raise ArgumentError, <<-ERROR.chomp
No assets found
          ERROR
        end
        return nodes
      end
    end
  end
end
