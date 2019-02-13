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
require 'inventoryware/commands'

require 'commander'
require 'ostruct'
require 'yaml'

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

    class << self
      def action(command, klass)
        command.action do |args, options|
          klass.new(args, options).run!
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
        command.option '--all', "Select all nodes"
        command.option '-g', '--group GROUP',
                       "Select nodes in GROUP, specify commma-separated list for multiple groups"
      end

      def add_create_option(command)
        command.option '-c', '--create',
                       "Create specified node(s) if they don't exist"
      end
    end

    command :parse do |c|
      cli_syntax(c, 'FILE')
      c.description = 'Parse and store inventory information'
      action(c, Commands::Parse)
    end

    command :modify do |c|
      cli_syntax(c)
      c.description = 'Change mutable node data'
      c.sub_command_group = true
    end

    command :'modify other' do |c|
      cli_syntax(c, 'KEY=VALUE [NODE...]')
      c.description = "Modify arbitrary data for one or more nodes"
      c.hidden = true
      add_multi_node_options(c)
      add_create_option(c)
      action(c, Commands::Modifys::Other)
    end

    command :'modify location' do |c|
      cli_syntax(c, '[NODE...]')
      c.description = "Modify location data for one or more nodes"
      c.hidden = true
      add_multi_node_options(c)
      add_create_option(c)
      action(c, Commands::Modifys::Location)
    end

    command :'modify groups' do |c|
      cli_syntax(c, 'GROUP [NODE...]')
      c.description = "Modify group data for one or more nodes"
      c.hidden = true
      add_multi_node_options(c)
      add_create_option(c)
      c.option '-p', '--primary', "Modify the primary group of one or more nodes"
      c.option '-r', '--remove', "Remove one or more nodes from this group"
      action(c, Commands::Modifys::Groups)
    end

    command :'modify map' do |c|
      cli_syntax(c, 'NODE')
      c.description = "Modify mapping data for a node"
      c.hidden = true
      add_create_option(c)
      action(c, Commands::Modifys::Map)
    end

    command :'modify notes' do |c|
      cli_syntax(c, 'NODE')
      c.description = "Modify miscellaneous notes for a node"
      c.hidden = true
      add_create_option(c)
      action(c, Commands::Modifys::Notes)
    end

    command :list do |c|
      cli_syntax(c)
      c.description = "List all nodes that have stored data"
      action(c, Commands::List)
    end

    command :edit do |c|
      cli_syntax(c, 'NODE')
      c.description = "Edit stored data for a node"
      add_create_option(c)
      action(c, Commands::Edit)
    end

    command :show do |c|
      cli_syntax(c)
      c.description = "View data"
      c.sub_command_group = true
    end

    command :'show data' do |c|
      cli_syntax(c, 'NODE')
      c.description = "View stored data for a node"
      c.hidden = true
      action(c, Commands::Shows::Data)
    end

    command :'show document' do |c|
      cli_syntax(c, 'TEMPLATE [NODE...]')
      c.description = "Render a document template for one or more nodes"
      c.option '-l', '--location LOCATION',
               "Output the rendered template to the specified location"
      c.option '-d', '--debug', "Display rendering errors"
      add_multi_node_options(c)
      c.hidden = true
      action(c, Commands::Shows::Document)
    end

    command :delete do |c|
      cli_syntax(c, '[NODE...]')
      c.description = "Delete the stored data for one or more nodes"
      add_multi_node_options(c)
      action(c, Commands::Delete)
    end
  end
end
