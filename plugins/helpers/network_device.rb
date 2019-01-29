def network_devices
  def create_net(net_hash)
    OpenStruct.new(net_hash).tap do |o|
      o.speed = format_bits_value((net_hash['capacity'] || net_hash['size'] || 0).to_i)
    end
  end
  network_devices = []
  find_hashes_with_key_value(@node_data, 'class', 'network')&.each do |net|
    network_devices << create_net(net)
  end
  network_devices
end
