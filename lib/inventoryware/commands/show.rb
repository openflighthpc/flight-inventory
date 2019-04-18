# =============================================================================
# Copyright (C) 2019-present Alces Flight Ltd.
#
# This file is part of Flight Inventory.
#
# This program and the accompanying materials are made available under
# the terms of the Eclipse Public License 2.0 which is available at
# <https://www.eclipse.org/legal/epl-2.0>, or alternative license
# terms made available by Alces Flight Ltd - please direct inquiries
# about licensing to licensing@alces-flight.com.
#
# Flight Inventory is distributed in the hope that it will be useful, but
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS OR
# IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR CONDITIONS
# OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR A
# PARTICULAR PURPOSE. See the Eclipse Public License 2.0 for more
# details.
#
# You should have received a copy of the Eclipse Public License 2.0
# along with Flight Inventory. If not, see:
#
#  https://opensource.org/licenses/EPL-2.0
#
# For more information on Flight Inventory, please visit:
# https://github.com/openflighthpc/flight-inventory
# ==============================================================================
require 'inventoryware/commands/multi_node_command'
require 'inventoryware/config'
require 'inventoryware/exceptions'
require 'inventoryware/node'
require 'inventoryware/templates_config'
require 'inventoryware/utils'

require 'erubis'
require 'recursive-open-struct'

module Inventoryware
  module Commands
    class Show < MultiNodeCommand
      def run
        nodes = fetch_nodes()
        nodes = nodes.sort_by { |node| node.name }

        output(nodes, @options.location)
      end

      private
      def output(nodes, out_dest)
        out = ""
        # check, will loading all output cause issues with memory size?
        # probably fine - 723 nodes was 350Kb
        nodes.each do |node|
          out += fill_template(node, find_template(node), render_env)
          # $stderr.puts "Rendered #{File.basename(node.path, '.yaml')}"
        end

        if out_dest
          # Confirm file location exists.
          # I decided against creating location if it did not exist as it
          # requires sudo execution - it may be that this would be better
          # changed.
          unless Utils.check_file_writable?(out_dest)
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

      def render_env
        render_env = Module.new do
          class << self
            attr_reader :asset_data
          end
        end

        Dir[File.join(Config.helpers_dir, '*.rb')].each do |file|
          render_env.instance_eval(File.read(file))
        end
        Dir["#{Config.plugins_dir}/*"].each do |plugin|
          Dir["#{plugin}/helpers/*.rb"].each do |file|
            render_env.instance_eval(File.read(file), file)
          end
        end

        return render_env
      end

      #If we want to speed up execution we should try only calling this
      # method once for all nodes when '@options.template' has a value
      # as the result will always been the same so it's wasted computation
      def find_template(node)
        template = if @options.template
                     find_template_as_path(@options.template)
                   else
                     TemplatesConfig.find(@options.format, node.type)
                   end

        if ! File.readable?(template)
          template_file = File.join(Config.templates_dir, template)
          if File.readable?(template_file)
            template = template_file
          else
            plugin = Dir["#{Config.plugins_dir}/*"].find do |plugin|
              File.readable?(File.join(plugin,'templates', template))
            end
            if plugin
              template = File.join(plugin, 'templates', template)
            else
              raise RuntimeError, <<-ERROR.chomp
Template '#{template}' was not found
              ERROR
            end
          end
        end

        return template
      end

      def find_template_as_path(template_arg)
        found = Utils.find_file(template_arg, Config.templates_dir)
        if found.length == 1
          template = found[0]
        elsif found.length > 1
          raise ArgumentError, <<-ERROR.chomp
Please refine your search and try again.
            ERROR
        else
          template = template_arg
        end
      end

      # fill the template for a single node
      def fill_template(node, template, render_env)
        template_contents = File.read(template)
        eruby = Erubis::Eruby.new(template_contents)

        asset_hash = node.data
        asset_data = RecursiveOpenStruct.new(
          asset_hash,
          recurse_over_arrays: true,
          preserve_original_keys: true
        )
        render_env.instance_variable_set(:@asset_data, asset_data)
        render_env.instance_variable_set(:@asset_hash, asset_hash)
        ctx = render_env.instance_eval { binding }

        begin
          return eruby.result(ctx)
        rescue StandardError => e
          unless @options.debug
            raise ParseError, <<-ERROR.chomp
Error filling template using #{File.basename(node.path)}.
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
