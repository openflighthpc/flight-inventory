
require 'erubis'

module Inventoryware
  module Commands
    class Render < Command
      def run
        other_args = ["template"]
        nodes = Utils::resolve_node_options(@argv, @options, other_args)

        #TODO DRY up definition of arguments? template is declared twice
        template = @argv[0]

        unless Utils::check_file_readable?(template)
          $stderr.puts "Error: Template at #{template} inaccessible"
          exit
        end

        out_file = nil
        # confirm file location exists
        # decided against creating location if it did not exist as it requires sudo
        #   execution - it may be that this would be better changed
        if @options.location
          unless Utils::check_file_writable?(@options.location)
            $stderr.puts "Error: Invalid destination '#{@options.location}'"
            exit
          end
          out_file = @options.location
        end

        node_locations = Utils::select_nodes(nodes, @options)
        output(node_locations, template, out_file)
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
