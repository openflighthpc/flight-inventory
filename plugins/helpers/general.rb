# sum the size of each bank of each memory node
def find_total_memory
  total = 0
  find_hashes_with_key_value(@node_hash, 'class', 'memory').each do |mem|
    find_hashes_with_key_value(mem, 'id', '^(bank:).*').each do |bank|
      total += bank['size'].to_i
    end
  end
  total
end
