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
def cpus
  def create_cpu(cpu_hash)
    OpenStruct.new(cpu_hash).tap do |o|
      o.model = cpu_hash['model'] || cpu_hash['version'] || cpu_hash['product'] || 'No model found'

      # Determine total number of cores
      ## For metal systems: Uses the "enabledcores" value from lscpu
      ## For VMs: Each CPU is 1 core (and no enabledcores setting exists)
      unless o['configuration'].nil?
        o.cores = find_hashes_with_key_value(o['configuration']['setting'], 'id', 'enabledcores')[0]['value'].to_i
      else
        o.cores = 1
      end
    end
  end
  cpus = []
  find_hashes_with_key_value(@asset_hash, 'description', 'CPU').each do |cpu_hash|
    cpus << create_cpu(cpu_hash)
  end
  cpus
end
