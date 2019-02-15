def cpus
  def create_cpu(cpu_hash)
    OpenStruct.new(cpu_hash).tap do |o|
      o.model = cpu_hash['model'] || cpu_hash['version'] || 'No model found'
    end
  end
  cpus = []
  find_hashes_with_key_value(@node_hash, 'class', 'processor').each do |cpu_hash|
    cpus << create_cpu(cpu_hash)
  end
  cpus
end
