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
require 'inventoryware/commands/multi_node_command'
require 'fileutils'

module Inventoryware
  module Commands
    class Delete < MultiNodeCommand
      def run
        node_locations = find_nodes()

        unless node_locations.empty?
          prefix = "You are about to delete"
          node_locations.map! { |loc| File.expand_path(loc) }
          if node_locations.length > 1
            node_msg = "#{prefix}:\n#{node_locations.join("\n")}\nProceed? (y/n)"
          else
            node_msg = "#{prefix} #{node_locations[0]} - proceed? (y/n)"
          end
          if $terminal.agree(node_msg)
            node_locations.each { |node| FileUtils.rm node }
          end
        else
          puts "No assets found"
        end
      end
    end
  end
end
