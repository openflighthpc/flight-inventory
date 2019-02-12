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
  module Utils
    # return a single file from glob, print error if >/< than 1 found
    def self.find_file(search_val, dir)
      results = Dir.glob(File.join(dir, "#{search_val}*"))
        if results.empty?
          puts "No files found for '#{search_val}' in #{File.expand_path(dir)}"
        elsif results.length > 1
          puts "Ambiguous search term '#{search_val}' - possible results are:"
          results.map! { |p| File.basename(p, File.extname(p)) }
          results.each_slice(3).each { |p| puts p.join("  ") }
        end
      return results
    end
  end
end
