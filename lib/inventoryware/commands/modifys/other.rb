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
      class Other < MultiNodeCommand
        def run
          modification = @argv[0]

          unless modification.match(/=/)
            raise ArgumentError, <<-ERROR.chomp
Invalid modification - must contain an '='
            ERROR
          end
          field, value = modification.split('=')

          protected_fields = ['primary_group', 'secondary_groups']
          if protected_fields.include?(field)
            raise ArgumentError, <<-ERROR.chomp
Cannot modify '#{field}' this way
            ERROR
          end

          fetch_nodes("modification").each do |node|
            type = Utils.get_new_asset_type if @options.create
            node.create_if_non_existent(type)
            if value
              node.data['mutable'][field] = value
            else
              node.data['mutable'].delete(field)
            end
            node.save
          end
        end
      end
    end
  end
end
