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
      class Map < SingleNodeCommand
        def action(node_data, location)
          map = map_to_string(node_data['mutable']['map'])
          map = string_to_map(edit_with_tmp_file(map, :"rvim +'set number'"))
          node_data['mutable']['map'] = map
          Utils::output_node_yaml(node_data, location)
        end

        # takes a hash with numerical keys
        # returns a string with the keys as line numbers
        def map_to_string(map)
          return '' if map.nil?
          return '' unless map.respond_to?(:key?)
          return '' if map.keys.length < 1

          unless map.keys.all? { |key| key.is_a? Integer }
            raise ParseError, <<-ERROR.chomp
Error parsing map - Non-integer keys
            ERROR
          end

          str = ''
          (1..map.keys.max).each do |i|
            str << map.fetch(i, '')
            str << "\n"
          end
          return str
        end

        # takes a string
        # returns a hash with each line being a different numerical key
        def string_to_map(str)
          map = Hash.new
          str.split("\n").each_with_index do |line, i|
            map[i+1] = line unless line.empty?
          end
          return map
        end
      end
    end
  end
end
