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
require 'inventoryware/exceptions'
require 'inventoryware/node'

module Inventoryware
  module Commands
    module Modifys
      class Groups < MultiNodeCommand
        def run
          if @options.primary and @options.remove
            raise ArgumentError, <<-ERROR.chomp
Cannot remove a primary group
            ERROR
          end

          group = @argv[0]

          fetch_nodes("group").each do |node|
            if @options.primary
              node.data['mutable']['primary_group'] = group
            else
              sec = node.data['mutable'].fetch('secondary_groups', nil)&.split(',')
              if @options.remove and sec.include?(group)
                sec.delete(group)
              elsif not @options.remove
                sec ? sec << group : sec = [group]
                sec.uniq!
              end
              node.data['mutable']['secondary_groups'] = sec.join(',')
            end
            node.save
          end
        end
      end
    end
  end
end
