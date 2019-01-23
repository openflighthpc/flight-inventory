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
    module Shows
      class Show < Command
        def run
          @value = @argv[0]
          found = find_target(@value)
          if found.empty?
            puts "No files found for '#{@value}'"
          elsif found.length > 1
            puts "Ambiguous search term '#{@value}' - possible results are:"
            found.map! { |p| File.basename(p) }
            found.each_slice(3).each { |p| puts p.join("  ") }
            puts "Please refine your search"
          else
            File.open (found[0]) do |file|
              puts file.read
            end
          end

        end

        def find_target
          raise NotImplementedError
        end
      end
    end
  end
end
