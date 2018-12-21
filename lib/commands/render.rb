
require 'erubis'

module Inventoryware
  module Commands
    class Render < Command
      def gen_ctx_with_plugins(hash, template)
        render_env = Module.new do
          def hash
            hash
          end
        end
        Dir[File.join(LIB_DIR, '..', 'plugins', '*.rb')].each do |file|
          render_env.instance_eval(File.read(file))
        end
        ctx = render_env.instance_eval { binding }
      end

      def find_all_nodes()
        node_locations = Dir.glob(File.join(YAML_DIR, '*.yaml'))
        if node_locations.empty?
          p "Error: No node data found in #{YAML_DIR}"
          exit
        end
        #TODO sort node_locations?
        return node_locations
      end

      def find_nodes(nodes)
        node_locations = []
        nodes.each do |node|
          node_yaml = "#{node}.yaml"
          node_yaml_location = File.join(YAML_DIR, node_yaml)
          unless check_file_readable?(node_yaml_location)
            puts "Error: File #{node_yaml} not found within #{File.expand_path(YAML_DIR)}"
            exit
          end
          node_locations.append(node_yaml_location)
        end
        return node_locations
      end

      def output(node_locations, template, out_file)
        # TODO verify template contents?
        template_contents = File.read(template)
        eruby = Erubis::Eruby.new(template_contents)

        out = ""
        # check, will loading all output cause issues with memory size?
        # probably fine - 723 nodes was 350Kb
        node_locations.each do |node|
          begin
            # `.values[0]` it ignore the name of the node & just get its data
            hash = YAML.load_file(node).values[0]
          rescue Psych::SyntaxError
            puts "Error: parsing yaml in #{node} - aborting"
            exit
          end

          #TODO do we need to generate the entire context for each node
          ctx = gen_ctx_with_plugins(hash, template_contents)
          out += eruby.result(ctx)
          p "Parsed #{File.basename(node)}"
        end

        File.open(out_file, 'w') do |file|
          file.write(out)
        end
      end

      def run
        if @options.all and not @argv.length == 1
          puts "Error: 'template' should be the only argument - all nodes are being parsed."
          exit
        elsif not @options.all and @argv.length < 2
          puts "Error: Please provide a template and at least one node."
          exit
        end

        template = @argv[0]
        nodes = @argv[1..-1]

        unless check_file_readable?(template)
          puts "Error: Template at #{template} inaccessible"
          exit
        end

        # confirm file location exists
        # decided against creating location if it did not exist as it requires sudo
        #   execution - it may be that this would be better changed
        if @options.location
          unless check_file_writable?(@options.location)
            puts "Error: Invalid destination '#{@options.location}'"
            exit
          end
          out_file = @options.location
        else
          exit_unless_dir(OUTPUT_DIR)
          template_out_name = "#{File.basename(template)}"
          out_file = File.join(OUTPUT_DIR, template_out_name)
        end

        output(@options.all ? find_all_nodes() : find_nodes(nodes),
               template,
               out_file
              )

      #TODO encapsulate
      end
    end
  end
end
