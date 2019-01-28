def select_bios
  product = @node_data['lshw']['list']['node']['product']
  product.downcase!
  product = product.split(' ')

  # we look for sub templates with increasingly short names
  #   we start with words 1 to n, then 1 to n-1 etc.
  # this function expects snake case tempaltes stored in a
  #   `templates/bios/` directory.
  # It is possible that all but the first line of this method should be moved
  #   to `erb_utils` as it will be repeated for all sub-template rendering but
  #   I need more usage examples to confirm this.
  while not product.empty?
    template = render_sub_template('bios', product.join('_'))
    if template
      return template
    end
    product.pop
  end

  return nil
end
