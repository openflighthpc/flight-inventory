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
def select_bios
  product = @asset_data.lshw.list.node.product rescue ''
  product = product.downcase.split(' ')

  # we look for sub templates with increasingly short names
  #   we start with words 1 to n, then 1 to n-1 etc.
  # this function expects kebab-case-templates stored in a
  #   `templates/bios/` directory.
  # It is possible that all but the first line of this method should be moved
  #   to `erb_utils` as it will be repeated for all sub-template rendering but
  #   I need more usage examples to confirm this.
  while not product.empty?
    template = render_sub_template('bios', product.join('-'))
    if template
      return template
    end
    product.pop
  end

  return nil
end
