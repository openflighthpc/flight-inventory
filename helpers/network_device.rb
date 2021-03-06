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
def network_devices
  def create_net(net_hash)
    OpenStruct.new(net_hash).tap do |o|
      o.speed = format_bits_value((net_hash['capacity'] || net_hash['size'] || 0).to_i)

      # Set speed for Virtual & Infiniband interfaces
      if o.speed == '0 bit/s' and o.logicalname&.match? /ib/
        o.speed = 'Infiniband'
      elsif o.speed == '0 bit/s'
        o.speed = 'Virtual'
      end

      # Handle logicalname for virtio devices (as information is buried in 'node' hash)
      if o.logicalname.nil?
        o.logicalname = o.node['logicalname']
      end

      # Handle mac address for virtio devices
      if o.serial.nil?
        o.serial = o.node['serial']
      end
    end
  end
  network_devices = []
  find_hashes_with_key_value(@asset_hash, 'class', 'network')&.each do |net|
    # Ignore virtual interfaces (bridges, tunnels and bonds)
    unless find_hashes_with_key_value(net['configuration']['setting'], 'id', 'driver$')[0]['value'].match? /bridge|tun|bonding/
      network_devices << create_net(net)
    end
  end
  network_devices.sort_by {|hsh| hsh[:logicalname] || ''}
end
