#==============================================================================
# Copyright (C) 2019-present Alces Flight Ltd.
#
# This file/package is part of Inventoryware.
#
# Inventoryware is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# Inventoryware is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this package.  If not, see <http://www.gnu.org/licenses/>.
#
# For more information on Inventoryware, please visit:
# https://github.com/openflighthpc/inventoryware
#==============================================================================
require 'inventoryware/commands/single_node_command'
require 'inventoryware/exceptions'

module Inventoryware
  module Commands
    module Modifys
      class Map < SingleNodeCommand
        def action(node)
          prompt = TTY::Prompt.new
          unless prompt.no?('Would you like to add map metadata? (Default: No)')
            get_map_metadata_from_user(node, prompt)
          end

          map = map_to_string(node.data['mutable']['map'])
          map = string_to_map(edit_with_tmp_file(map, :"rvim +'set number'"))
          node.data['mutable']['map'] = map
          node.save
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
          str.lines.map(&:chomp).each_with_index do |line, i|
            map[i+1] = line
          end
          return map
        end

        def get_map_metadata_from_user(node, prompt)
          prompt.say('Enter integer values for the dimensions of the map:')

          x = prompt.ask('X:') do |q|
            q.validate(/^[0-9]+$/, 'Value must be an integer')
          end

          y = prompt.ask('Y:') do |q|
            q.validate(/^[0-9]+$/, 'Value must be an integer')
          end

          pattern = prompt.select(
            'Choose the pattern for the map:',
            %w(DownRight RightDown RightUp UpRight)
          )

          node.data['mutable']['map_dimensions'] = "#{x}x#{y}"
          node.data['mutable']['map_pattern'] = pattern
        end
      end
    end
  end
end
