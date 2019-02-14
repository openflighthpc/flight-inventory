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

          find_nodes("group").each do |location|
            node= Node.new(location)
            node.create_if_non_existent
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
