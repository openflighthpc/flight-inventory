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
      class Map < MultiNodeCommand
        def run
          nodes = fetch_nodes()
          node = nodes.first
          map_name = @argv.first

          prompt = TTY::Prompt.new
          unless prompt.no?('Would you like to add map metadata? (Default: No)')
            get_map_metadata_from_user(map_name, nodes, prompt)
          end

          map = map_to_string(node.data['mutable']['maps'][map_name]['map'])
          map = string_to_map(Utils.edit_with_tmp_file(map,
                                                       :"rvim +'set number'"))

          nodes.each do |node|
            node.data['mutable']['maps'][map_name]['map'] = map
            node.save
          end
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

        def get_map_metadata_from_user(map_name, nodes, prompt)
          prompt.say('Enter integer values for the dimensions of the map:')

          x = prompt.ask('Width:') do |q|
            q.validate(/^[0-9]+$/, 'Value must be an integer')
          end

          y = prompt.ask('Height:') do |q|
            q.validate(/^[0-9]+$/, 'Value must be an integer')
          end

          choices = {
            'Down then right (starting at top-left)' => 't-l-v',
            'Right the down (starting at top-left)' => 't-l-h',
            'Up then right (starting at bottom-left)' => 'b-l-v',
            'Right then up (starting at bottom-left)' => 'b-l-h'
          }
          layout = prompt.select('Choose the pattern for the map:', choices)

          nodes.each do |node|
            mutable = node.data['mutable']
            maps = mutable.fetch('maps') { mutable['maps'] = {} }
            map = maps.fetch(map_name) { maps[map_name] = {} }

            map['map_height'] = y
            map['map_width'] = x
            map['map_layout'] = layout
          end
        end
      end
    end
  end
end
