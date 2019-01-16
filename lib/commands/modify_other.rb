
module Inventoryware
  module Commands
    class ModifyOther < Command
      def run
        other_args = ["modification"]
        nodes = Utils::resolve_node_options(@argv, @options, other_args)

        #TODO DRY up? modification is defined twice
        modification = @argv[0]
        unless modification.match(/=/)
          raise ArgumentError, <<-ERROR
Invalid modification - must contain an '='.
          ERROR
        end
        field, value = modification.split('=')

        protected_fields = ['primary_group', 'secondary_groups']
        if protected_fields.include?(field)
          raise ArgumentError, <<-ERROR
Cannot modify '#{field}' this way.
          ERROR
        end

        node_locations = Utils::select_nodes(nodes,
                                             @options,
                                             return_missing = true)

        node_locations.each do |location|
          node_data = Utils::read_node_or_create(location)
          if value
            node_data['mutable'][field] = value
          else
            node_data['mutable'].delete(field)
          end
          Utils::output_node_yaml(node_data, location)
        end
      end
    end
  end
end
