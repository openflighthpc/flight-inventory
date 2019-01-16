
module Inventoryware
  module Commands
    class ModifyGroups < Command
      def run
        other_args = ["group"]
        nodes = Utils::resolve_node_options(@argv, @options, other_args)

        if @options.primary and @options.remove
          $stderr.puts "Error: cannot remove a primary group"
          exit
        end

        #TODO DRY up? group is defined twice
        group = @argv[0]

        node_locations = Utils::select_nodes(nodes,
                                             @options,
                                             return_missing = true)

        node_locations.each do |location|
          node_data = Utils::read_node_or_create(location)
          if @options.primary
            node_data['mutable']['primary_group'] = group
          else
            sec = node_data['mutable'].fetch('secondary_groups', nil)&.split(',')
            if @options.remove and sec.include?(group)
              sec.delete(group)
            elsif not @options.remove
              sec ? sec << group : sec = [group]
              sec.uniq!
            end
            node_data['mutable']['secondary_groups'] = sec.join(',')
          end
          Utils::output_node_yaml(node_data, location)
        end
      end
    end
  end
end
