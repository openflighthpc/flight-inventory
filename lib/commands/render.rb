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

        node_locations = Utils::select_nodes(nodes, @options)
        node_locations = node_locations.uniq
        node_locations = node_locations.sort_by do |location|
          File.basename(location)
        end

        output(node_locations, template, @options.location)
      end

      def output(node_locations, template, out_dest)
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

        args = [node_locations, eruby, render_env]
        if out_dest
          output_render(*args.push(out_dest))
        else
          template_name = File.basename(template, File.extname(template))
          save_renders(*(args.push(template_name)))
        end
      end

      def save_renders(node_locations, eruby, render_env, template_name)
        node_locations.each do |location|
          out = fill_template(location, eruby, render_env)
          node_name = File.basename(location, '.yaml')
          out_dest = File.join(RENDERS_DIR, "#{node_name}_#{template_name}")
          unless Utils::check_file_writable?(out_dest)
            raise FileSysError, <<-ERROR
Output file #{out_dest} not accessible - aborting
            ERROR
          end
          File.open(out_dest, 'w') do |file|
            file.write(out)
          end
          puts "Rendered #{node_name} to #{out_dest}"
        end
      end

      def output_render(node_locations, eruby, render_env, out_dest)
        out = ""
        # check, will loading all output cause issues with memory size?
        # probably fine - 723 nodes was 350Kb
        node_locations.each do |location|
          out += fill_template(location, eruby, render_env)
          puts "Rendered #{File.basename(location, '.yaml')}"
        end

        # Confirm file location exists.
        # I decided against creating location if it did not exist as it
        # requires sudo execution - it may be that this would be better
        # changed.
        unless Utils::check_file_writable?(out_dest)
          raise ArgumentError, <<-ERROR
Invalid destination '#{out_dest}'
          ERROR
        end
        File.open(out_dest, 'w') do |file|
          file.write(out)
        end
      end

      # fill the template for a single node
      def fill_template(node_location, eruby, render_env)
        # `.values[0]` ignores the name of the node & gets just its data
        node_data = Utils::read_node_yaml(node_location).values[0]
        render_env.instance_variable_set(:@node_data, node_data)
        ctx = render_env.instance_eval { binding }

        return eruby.result(ctx)
      end
    end
  end
end
