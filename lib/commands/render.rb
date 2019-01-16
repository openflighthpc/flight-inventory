#==============================================================================
# Copyright (C) 2018-19 Stephen F. Norledge and Alces Software Ltd.
#
# This file/package is part of Alces Inventoryware.
#
# Alces Inventoryware is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# Alces Inventoryware is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this package.  If not, see <http://www.gnu.org/licenses/>.
#
# For more information on Alces Inventoryware, please visit:
# https://github.com/alces-software/inventoryware
#==============================================================================

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
          raise ArgumentError, <<-ERROR
Template at #{template} inaccessible
          ERROR
        end

        out_file = nil
        # confirm file location exists
        # decided against creating location if it did not exist as it requires sudo
        #   execution - it may be that this would be better changed
        if @options.location
          unless Utils::check_file_writable?(@options.location)
            raise ArgumentError, <<-ERROR
Invalid destination '#{@options.location}'
            ERROR
          end
          out_file = @options.location
        end

        node_locations = Utils::select_nodes(nodes, @options)
        node_locations = node_locations.uniq
        node_locations = node_locations.sort_by do |location|
          File.basename(location)
        end

        output(node_locations, template, out_file)
      end

      def output(node_locations, template, out_file)
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
          # '$stdout' here is just for clarity
          $stdout.puts out
        end
      end

      # fill the template for a single node
      def parse_yaml(node_location, eruby, render_env)
        # `.values[0]` ignores the name of the node & gets just its data
        node_data = Utils::read_node_yaml(node_location).values[0]
        render_env.instance_variable_set(:@node_data, node_data)
        ctx = render_env.instance_eval { binding }

        return eruby.result(ctx)
      end
    end
  end
end
