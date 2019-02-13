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
require 'recursive-open-struct'

module Inventoryware
  module Commands
    module Shows
      class Document < MultiNodeCommand
        def run
          template_arg = @argv[0]

          found = Utils::find_file(template_arg, Config.templates_dir)

          if found.length == 1
            template = found[0]
          elsif found.length > 1
            raise ArgumentError, <<-ERROR.chomp
Please refine your search and try again.
            ERROR
          else
            if not Utils::check_file_readable?(template_arg)
              raise ArgumentError, <<-ERROR.chomp
Template at #{template_arg} inaccessible
              ERROR
            end
            template = template_arg
          end

          node_locations = find_nodes('template')
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

          Dir[File.join(Config.helpers_dir, '*.rb')].each do |file|
            render_env.instance_eval(File.read(file))
          end

          out = ""
          # check, will loading all output cause issues with memory size?
          # probably fine - 723 nodes was 350Kb
          node_locations.each do |location|
            out += fill_template(Node.new(location), eruby, render_env)
            $stderr.puts "Rendered #{File.basename(location, '.yaml')}"
          end

          if out_dest
            # Confirm file location exists.
            # I decided against creating location if it did not exist as it
            # requires sudo execution - it may be that this would be better
            # changed.
            unless Utils::check_file_writable?(out_dest)
              raise ArgumentError, <<-ERROR.chomp
Invalid destination '#{out_dest}'
              ERROR
            end
            File.open(out_dest, 'w') do |file|
              file.write(out)
            end
          elsif not out.empty?
            $stdout.puts out
          end
        end

        # fill the template for a single node
        def fill_template(node, eruby, render_env)
          node_hash = node.data
          node_data = RecursiveOpenStruct.new(
                        node_hash,
                        recurse_over_arrays: true,
                        preserve_original_keys: true
                      )
          render_env.instance_variable_set(:@node_data, node_data)
          render_env.instance_variable_set(:@node_hash, node_hash)
          ctx = render_env.instance_eval { binding }

          begin
            return eruby.result(ctx)
          rescue StandardError => e
            unless @options.debug
              raise ParseError, <<-ERROR.chomp
Error filling template using #{File.basename(node_location)}.
Use '--debug' for more information
              ERROR
            else
              raise e
            end
          end
        end
      end
    end
  end
end
