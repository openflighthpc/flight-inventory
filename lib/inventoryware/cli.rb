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
require 'inventoryware/commands'

require 'commander'
require 'ostruct'
require 'yaml'
require 'paint'

module Inventoryware
  module CLI
    PROGRAM_NAME = ENV.fetch('FLIGHT_PROGRAM_NAME','inventory')

    extend Commander::Delegates
    program :name, PROGRAM_NAME
    program :version, '1.0.0'
    program :description, 'Parser of hardware information into unified formats.'
    program :help_paging, false

    # Display the help if there is no input arguments
    ARGV.push '--help' if ARGV.empty?

    silent_trace!

    error_handler do |e|
      $stderr.puts "#{Paint[PROGRAM_NAME, '#2794d8']}: #{Paint[e.to_s, :red]}"
      case e
      when OptionParser::InvalidOption,
           Commander::Runner::InvalidCommandError,
           Commander::Patches::CommandUsageError
        $stderr.puts "\nUsage:\n\n"
        args = ARGV.reject{|o| o[0] == '-'}
        if command(topic = args[0..1].join(" "))
          command("help").run(topic)
        elsif command(args[0])
          command("help").run(args[0])
        else
          command("help").run
        end
      end
      exit(1)
    end

    class << self
      def action(command, klass)
        command.action do |args, options|
          klass.new(args, options, command.name).run!
        end
      end

      def cli_syntax(command, args_str = nil)
        command.syntax = [
          PROGRAM_NAME,
          command.name,
          args_str
        ].compact.join(' ')
      end

      def add_multi_node_options(command)
        command.option '--all', "Select all assets"
        add_group_option(command)
      end

      def add_create_option(command)
        command.option '-c', '--create',
          "Create specified asset(s) if they don't exist"
      end

      def add_group_option(command)
        command.option '-g', '--group GROUP',
          "Select assets in GROUP, specify comma-separated list for multiple groups"
      end
    end

    command :parse do |c|
      cli_syntax(c, 'FILE')
      c.description = 'Parse and store inventory information'
      action(c, Commands::Parse)
    end

    command :modify do |c|
      cli_syntax(c, 'SUBCOMMAND')
      c.description = 'Change mutable asset data'
      c.configure_sub_command(self)
    end

    command :'modify other' do |c|
      cli_syntax(c, 'KEY=VALUE [ASSET_SPEC]')
      c.description = "Modify arbitrary data for one or more assets"
      c.hidden = true
      add_multi_node_options(c)
      add_create_option(c)
      action(c, Commands::Modifys::Other)
    end

    command :'modify groups' do |c|
      cli_syntax(c, 'GROUP [ASSET_SPEC]')
      c.description = "Modify group data for one or more assets"
      c.hidden = true
      add_multi_node_options(c)
      add_create_option(c)
      c.option '-p', '--primary', "Modify the primary group of one or more assets"
      c.option '-r', '--remove', "Remove one or more assets from this group"
      action(c, Commands::Modifys::Groups)
    end

    command :'modify map' do |c|
      cli_syntax(c, '[ASSET_SPEC]')
      c.description = "Modify mapping data for one or more assets"
      c.hidden = true
      add_multi_node_options(c)
      add_create_option(c)
      action(c, Commands::Modifys::Map)
    end

    command :'modify notes' do |c|
      cli_syntax(c, '[ASSET_SPEC]')
      c.description = "Modify miscellaneous notes for one or more assets"
      c.hidden = true
      add_multi_node_options(c)
      add_create_option(c)
      action(c, Commands::Modifys::Notes)
    end

    command :list do |c|
      cli_syntax(c)
      c.description = "List all assets that have stored data"
      add_group_option(c)
      action(c, Commands::List)
    end

    command :edit do |c|
      cli_syntax(c, 'ASSET')
      c.description = "Edit stored data for an asset"
      add_create_option(c)
      action(c, Commands::Edit)
    end

    command :show do |c|
      cli_syntax(c, 'SUBCOMMAND')
      c.description = "View data"
      c.configure_sub_command(self)
    end

    command :'show data' do |c|
      cli_syntax(c, 'ASSET')
      c.description = "View stored data for an asset"
      c.hidden = true
      action(c, Commands::Shows::Data)
    end

    command :'show document' do |c|
      cli_syntax(c, '[ASSET_SPEC]')
      c.description = "Render a document template for one or more assets"
      c.option '-t', '--template TEMPLATE',
        "Render this specific template\n"\
        "Otherwise use the asset's type to determine the target template "\
        "from a config file."
      c.option '-l', '--location LOCATION',
               "Output the rendered template to the specified location"
      c.option '-d', '--debug', "Display rendering errors"
      c.option '-f', '--format FORMAT',
              'Specify the type of template you would like to render'
      add_multi_node_options(c)
      c.hidden = true
      action(c, Commands::Shows::Document)
    end

    command :delete do |c|
      cli_syntax(c, '[ASSET_SPEC]')
      c.description = "Delete the stored data for one or more assets"
      add_multi_node_options(c)
      action(c, Commands::Delete)
    end

    command :create do |c|
      cli_syntax(c, 'ASSET')
      c.description = "Create a new asset"
      action(c, Commands::Edit)
    end
  end
end
