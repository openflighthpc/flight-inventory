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
