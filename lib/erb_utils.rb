#value' can be a regular expression or a plain old string
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
