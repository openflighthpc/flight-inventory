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
    module Modifiers
      class Location < Command
        def run
          other_args = []
          nodes = Utils::resolve_node_options(@argv, @options, other_args)
          node_locations = Utils::select_nodes(nodes, @options)

          fields = {
            'site' => {'name' => nil, 'value' => nil},
            'room' => {'name' => nil, 'value' => nil},
            'rack' => {'name' => nil, 'value' => nil},
            'start_unit' => {'name' => 'starting rack unit', 'value' => nil},
          }

          # Get input REPL style
          fields.each do |field, hash|
            name = hash['name'] ? hash['name'] : field
            value = ask("Enter a #{name} or press enter to skip")
            hash['value'] = value unless value == ''
          end

          # save data
          node_locations.each do |location|
            node_data = Utils::read_node_or_create(location)
            fields.each do |field, hash|
              if hash['value']
                node_data['mutable'][field] = hash['value']
              end
            end
            Utils::output_node_yaml(node_data, location)
          end
        end
      end
    end
  end
end
