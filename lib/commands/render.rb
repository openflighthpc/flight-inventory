
require 'erubis'

module Inventoryware
  module Commands
    class Render < Command
      def run
        if @options.all and not @argv.length == 1
          $stderr.puts "Error: 'template' should be the only argument - all "\
            "nodes are being parsed."
          exit
        elsif not @options.all and @argv.length < 2
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

        output(@options.all ? find_all_nodes() : find_nodes(nodes),
               template,
               out_file
              )
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

      def find_nodes(nodes)
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
        node_locations = node_locations.sort_by do |location|
          File.basename(location)
        end

        # TODO verify template contents?
        template_contents = File.read(template)
        eruby = Erubis::Eruby.new(template_contents)

        render_env = Module.new do
          class << self
            attr_reader :hash
          end
        end
        Dir[File.join(LIB_DIR, '..', 'plugins', '*.rb')].each do |file|
          render_env.instance_eval(File.read(file))
        end

        out = ""
        # check, will loading all output cause issues with memory size?
        # probably fine - 723 nodes was 350Kb
        node_locations.each do |node|
          out += parse_yaml(node, eruby, render_env)
          # this message is output through stderr in order to not interfere
          # with the output of the rendered template
          $stderr.puts "Rendered #{File.basename(node)}"
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

      def parse_yaml(node, eruby, render_env)
        begin
          # `.values[0]` ignores the name of the node & gets just its data
          hash = YAML.load_file(node).values[0]
        rescue Psych::SyntaxError
          $stderr.puts "Error: parsing yaml in #{node} - aborting"
          exit
        end
        render_env.instance_variable_set(:@hash, hash)
        ctx = render_env.instance_eval { binding }

        return eruby.result(ctx)
      end
    end
  end
end
