
require 'erubis'

module Inventoryware
  module Commands
    class Render < Command
      def run
        if @options.all
          unless @argv.length == 1
            $stderr.puts "Error: 'template' should be the only argument - all "\
              "nodes are being parsed."
            exit
          end
        elsif not @options.group and @argv.length < 2
          $stderr.puts "Error: Please provide a template and at least one "\
            "node."
          exit
        end

        template = @argv[0]
        nodes = @argv[1..-1]

        unless check_file_readable?(template)
          $stderr.puts "Error: Template at #{template} inaccessible"
          exit
        end

        out_file = nil
        # confirm file location exists
        # decided against creating location if it did not exist as it requires sudo
        #   execution - it may be that this would be better changed
        if @options.location
          unless check_file_writable?(@options.location)
            $stderr.puts "Error: Invalid destination '#{@options.location}'"
            exit
          end
          out_file = @options.location
        end

        if @options.all
          node_locations = find_all_nodes
        else
          if nodes
            single_nodes = find_nodes(nodes)
          end
          if @options.group
            groups_nodes = find_nodes_in_groups(@options.group.split(','))
          end
          node_locations = single_nodes + groups_nodes
        end

        output(node_locations, template, out_file)
      end

      private
      def find_all_nodes()
        node_locations = Dir.glob(File.join(YAML_DIR, '*.yaml'))
        if node_locations.empty?
          $stderr.puts "Error: No node data found in #{YAML_DIR}"
          exit
        end
        return node_locations
      end

      # this quite an intensive method of way to go about searching the yaml
      # each file is converted to a sting and then searched
      # seems fine as it stands but if speed becomes an issue could stand to
      #   be changed
      def find_nodes_in_groups(groups)
        nodes = []
        find_all_nodes().each do |location|
          found = []
          File.open(location) do |file|
            contents = file.read
            m = contents.match(/primary_group: (.*?)$/)[1]
            found.append(m) unless m.empty?
            m = contents.match(/secondary_groups: (.*?)$/)[1]
            found = found + (m.split(',')) unless m.empty?
          end
          unless (found & groups).empty?
            nodes.append(location)
          end
        end
        if nodes.empty?
          $stderr.puts "Error: no nodes in #{groups.join(', ')} found - exiting"
          exit
        end
        return nodes
      end

      def find_nodes(nodes)
        nodes = expand_node_ranges(nodes)
        node_locations = []
        nodes.each do |node|
          node_yaml = "#{node}.yaml"
          node_yaml_location = File.join(YAML_DIR, node_yaml)
          unless check_file_readable?(node_yaml_location)
            $stderr.puts "Error: File #{node_yaml} not found within "\
              "#{File.expand_path(YAML_DIR)}"
            exit
          end
          node_locations.append(node_yaml_location)
        end
        return node_locations
      end

      def output(node_locations, template, out_file)
        node_locations = node_locations.uniq

        node_locations = node_locations.sort_by do |location|
          File.basename(location)
        end

        # TODO verify template contents?
        template_contents = File.read(template)
        eruby = Erubis::Eruby.new(template_contents)

        render_env = Module.new do
          class << self
            attr_reader :node_data
          end
        end
        Dir[File.join(LIB_DIR, '..', 'plugins', '*.rb')].each do |file|
          render_env.instance_eval(File.read(file))
        end

        out = ""
        # check, will loading all output cause issues with memory size?
        # probably fine - 723 nodes was 350Kb
        node_locations.each do |location|
          out += parse_yaml(location, eruby, render_env)
          # this message is output through stderr in order to not interfere
          # with the output of the rendered template
          $stderr.puts "Rendered #{File.basename(location)}"
        end

        if out_file
          File.open(out_file, 'w') do |file|
            file.write(out)
          end
        else
          # '$stdout' here is just to be explicit - for clarity
          $stdout.puts out
        end
      end

      def parse_yaml(node_location, eruby, render_env)
        begin
          # `.values[0]` ignores the name of the node & gets just its data
          node_data = YAML.load_file(node_location).values[0]
        rescue Psych::SyntaxError
          $stderr.puts "Error: parsing yaml in #{node_location} - aborting"
          exit
        end
        render_env.instance_variable_set(:@node_data, node_data)
        ctx = render_env.instance_eval { binding }

        return eruby.result(ctx)
      end
    end
  end
end
