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

# 'value' can be a regular expression or a plain old string
def find_hashes_with_key_value(obj, key, value, store = [])
  if obj.respond_to?(:key?) && obj.key?(key) && /#{value}/.match(obj[key])
    store.push(obj)
  else
    obj.each do |elem|
      if elem.is_a? Enumerable
        find_hashes_with_key_value(elem, key, value, store)
      end
    end
  end
  return store
end

# sum the size of each bank of each memory node
def find_total_memory(hash)
  total = 0
  find_hashes_with_key_value(hash, 'class', 'memory').each do |mem|
    find_hashes_with_key_value(mem, 'id', '^(bank:).*').each do |bank|
      total += bank['size'].to_i
    end
  end
  total
end

# convert decimal amount of bits to a human readable format
def format_bits_value(bits_value)
  format_data_value(bits_value, 1000, 'bit/s')
end

# convert binary amount of bytes to a human readable format
def format_bytes_value(bytes_value)
  format_data_value(bytes_value, 1024, 'iB')
end

def format_data_value(orig_value, grouping, suffix)
  value = orig_value
  counter = 0
  while value >= grouping
    counter += 1
    value /= grouping
  end
  (value*grouping).round / grouping.to_f
  case counter
  when 0
    prefix = ''
  when 1
    prefix = 'K'
  when 2
    prefix = 'M'
  when 3
    prefix = 'G'
  when 4
    prefix = 'T'
  when 5
    prefix = 'P'
  else
    prefix = ''
  end
  # prevent errors if the counter gets too large, return original value
  if prefix == ''
    "#{orig_value} #{suffix}"
  else
    "#{value} #{prefix}#{suffix}"
  end
end
