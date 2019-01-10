
module Inventoryware
  module Commands
    class Modify < Command
      def run
        other_args = ["field", "value"]
        nodes = Utils::resolve_node_options(@argv, @options, other_args)

        #TODO DRY up? field and value are defined twice
        field, value = @argv[0..1]

        node_locations = Utils::select_nodes(nodes, @options)

        node_locations.each do |location|
          node_data = Utils.read_node_yaml(location).values[0]
          node_data['mutable'][field] = value
          Utils::output_node_yaml(node_data, location)
        end
      end
    end
  end
end
