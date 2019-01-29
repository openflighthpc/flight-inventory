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

module Inventoryware
  module Commands
    module Modifys
      class Other < Command
        def run
          other_args = ["modification"]
          nodes = Utils::resolve_node_options(@argv, @options, other_args)

          #TODO DRY up? modification is defined twice
          modification = @argv[0]
          unless modification.match(/=/)
            raise ArgumentError, <<-ERROR.chomp
  Invalid modification - must contain an '='.
            ERROR
          end
          field, value = modification.split('=')

          protected_fields = ['primary_group', 'secondary_groups']
          if protected_fields.include?(field)
            raise ArgumentError, <<-ERROR.chomp
  Cannot modify '#{field}' this way.
            ERROR
          end

          node_locations = Utils::select_nodes(nodes,
                                               @options,
                                               return_missing = true)

          node_locations.each do |location|
            node_data = Utils::read_node_or_create(location)
            if value
              node_data['mutable'][field] = value
            else
              node_data['mutable'].delete(field)
            end
            Utils::output_node_yaml(node_data, location)
          end
        end
      end
    end
  end
end
