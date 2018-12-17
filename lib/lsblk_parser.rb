#==============================================================================
# Copyright (C) 2018 Stephen F. Norledge and Alces Software Ltd.
#
# This file/package is part of Alces inventoryware.
#
# Alces inventoryware is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# Alces inventoryware is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this package.  If not, see <http://www.gnu.org/licenses/>.
#
# For more information on Alces inventoryware, please visit:
# https://github.com/alces-software/inventoryware
#==============================================================================

# Only designed on lsblk output with the -a (all) and 
# -P (key/value pairs) options
class LsblkParser
  def initialize(file)
    f = File.open(file)
    f_rows = f.read.split("\n")
    f.close
    @rows = f_rows.map { |row| LsblkRow.new(row) }
  end

  def hashify()
    hash = {}
    @rows.each do |row|
      if !hash[row.type]
        hash[row.type] = {}
      end
      hash[row.type][row.name] = {
        'MAJ:MIN' => row.maj_min,
        'RM' => row.rm,
        'SIZE' => row.size,
        'RO' => row.ro,
        'MOUNTPOINT' => row.mountpoint
      }
    end
    return hash
  end

  class LsblkRow
    attr_reader :name, :type, :size, :maj_min, :rm, :ro, :mountpoint

    def initialize(row)
      @row = row
      @name = find_value('NAME')
      @type = find_value('TYPE')
      @size = find_value('SIZE')
      @maj_min = find_value('MAJ:MIN')
      @rm = find_value('RM')
      @ro = find_value('RO')
      @mountpoint = find_value('MOUNTPOINT')

    end

    def find_value(key)
      /#{key}="(.*?)"/.match(@row)[1]
    end
  end
end
