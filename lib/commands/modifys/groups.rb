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

#TODO extract shared `Modifys` code to top level 'modify.rb' command file
module Inventoryware
  module Commands
    module Modifys
      class Groups < Command
        def run
          other_args = ["group"]
          Utils::resolve_node_options(@argv, @options, other_args)

          if @options.primary and @options.remove
            raise ArgumentError, <<-ERROR.chomp
Cannot remove a primary group
            ERROR
          end

          group = @argv[0]
          nodes = @argv.dig(1)

          node_locations = Utils::select_nodes(nodes,
                                               @options,
                                               return_missing = true)

          node_locations.each do |location|
            node_data = Utils::read_node_or_create(location)
            if @options.primary
              node_data['mutable']['primary_group'] = group
            else
              sec = node_data['mutable'].fetch('secondary_groups', nil)&.split(',')
              if @options.remove and sec.include?(group)
                sec.delete(group)
              elsif not @options.remove
                sec ? sec << group : sec = [group]
                sec.uniq!
              end
              node_data['mutable']['secondary_groups'] = sec.join(',')
            end
            Utils::output_node_yaml(node_data, location)
          end
        end
      end
    end
  end
end
