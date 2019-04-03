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
require 'inventoryware/commands/single_node_command'

module Inventoryware
  module Commands
    module Shows
      class Data < SingleNodeCommand
        def action(node)
          if @options.map
            read_map(node, @options.map)
          else
            output_file(node.path)
          end
        end

        def output_file(path)
          File.open(path) do |file|
            puts file.read
          end
        end

        def read_map(node, index)
          unless index.to_i.to_s == index
            raise ArgumentError, <<-ERROR.chomp
Please provide an integer index
            ERROR
          end

          index = index.to_i

          unless node.data.dig('mutable', 'map')
            raise InventorywareError, <<-ERROR.chomp
Asset #{node.name} does not have map data
            ERROR
          end

          unless node.data.dig('mutable', 'map', index)
            raise InventorywareError, <<-ERROR.chomp
Asset #{node.name}'s map does not have an index #{index}
            ERROR
          end

          line = node.data['mutable']['map'][index]

          asset_names = Dir[File.join(Config.yaml_dir, '*')].map do |p|
            p = File.basename(p, File.extname(p))
          end

          asset_names.select! { |name| line.include?(name) }

          if asset_names.empty?
            puts "No assets found under that index"
          else
            puts asset_names
          end
        end
      end
    end
  end
end
