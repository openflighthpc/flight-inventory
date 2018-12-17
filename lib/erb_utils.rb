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
