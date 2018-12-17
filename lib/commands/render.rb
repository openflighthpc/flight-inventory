
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

      def run
        unless @argv.length == 2
          puts "Error: 'node' and 'template' should be the only arguments"
          exit
        end

        node = @argv[0]
        template = @argv[1]

        unless check_file?(template)
          puts "Error: Template at #{template} inaccessible"
          exit
        end

        node_yaml = "#{node}.yaml"
        node_yaml_location = File.join(YAML_DIR, node_yaml)
        unless check_file?(node_yaml_location)
          puts "Error: File #{node_yaml} not found within #{File.expand_path(YAML_DIR)}"
          exit
        end

        begin
          hash = YAML.load_file(node_yaml_location)[node]
        rescue Psych::SyntaxError
          puts "Error: parsing yaml in #{node_yaml_location} - aborting"
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
          template_out_name = "#{node}_#{File.basename(template)}"
          out_file = File.join(OUTPUT_DIR, template_out_name)
        end

        # output
        # TODO verify template contents?
        template_contents = File.read(template)
        eruby = Erubis::Eruby.new(template_contents)
        File.open(out_file, 'w') do |file|
          file.write(eruby.result(gen_ctx_with_plugins(hash, template_contents)))
        end
      end
    end
  end
end
