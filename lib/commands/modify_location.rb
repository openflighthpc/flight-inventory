
module Inventoryware
  module Commands
    class ModifyLocation < Command
      def run
        other_args = []
        nodes = Utils::resolve_node_options(@argv, @options, other_args)
        node_locations = Utils::select_nodes(nodes, @options)

        fields = {
          'site' => {'name' => nil, 'value' => nil},
          'room' => {'name' => nil, 'value' => nil},
          'rack' => {'name' => nil, 'value' => nil},
          'start_unit' => {'name' => 'starting rack unit', 'value' => nil},
          'chassis' => {'name' => nil, 'value' => nil},
          'slot' => {'name' => nil, 'value' => nil}
        }

        # Get input REPL style
        fields.each do |field, hash|
          name = hash['name'] ? hash['name'] : field
          p "Enter a #{name} or press enter to skip"
          # TODO swap gets for use of highline gem?
          value = STDIN.gets.chomp
          hash['value'] = value unless value == ''
        end

        # save data
        node_locations.each do |location|
          node_data = Utils::read_node_or_create(location)
          fields.each do |field, hash|
            if hash['value']
              node_data['mutable'][field] = hash['value']
            end
          end
          Utils::output_node_yaml(node_data, location)
        end
      end
    end
  end
end
