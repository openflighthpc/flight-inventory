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
