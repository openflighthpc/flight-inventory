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
require 'inventoryware/version'

require 'commander'
require 'ostruct'
require 'yaml'

module Inventoryware
  module CLI
    PROGRAM_NAME = ENV.fetch('FLIGHT_PROGRAM_NAME','inventory')

    extend Commander::Delegates
    program :application, "Flight Inventory"
    program :name, PROGRAM_NAME
    program :version, "v#{Inventoryware::VERSION}"
    program :description, 'Parser of hardware information into unified formats.'
    program :help_paging, false
    default_command :help
    silent_trace!

    class << self
      def cli_syntax(command, args_str = nil)
        command.syntax = [
          PROGRAM_NAME,
          command.name,
          args_str
        ].compact.join(' ')
      end

      def add_multi_node_options(command)
        command.option '--all', "Select all assets"
        command.option '-g', '--group GROUP',
          "Select assets in GROUP, specify comma-separated list for multiple groups"
      end
    end

    command :create do |c|
      cli_syntax(c, 'ASSET')
      c.description = "Create a new asset"
      c.action Commands, :create
    end

    command :import do |c|
      cli_syntax(c, 'FILE')
      c.description = 'Parse and store inventory information'
      c.action Commands, :import
    end

    command :'import-hunter' do |c|
      cli_syntax(c, 'FILE')
      c.description = 'Parse and store inventory information from a Hunter-sourced YAML'
      c.action Commands, :'import_hunter'
    end

    command :'modify-other' do |c|
      cli_syntax(c, 'KEY=VALUE [ASSET_SPEC]')
      c.description = "Modify arbitrary data for one or more assets"
      add_multi_node_options(c)
      c.action Commands, :'modifys-other'
    end

    command :'edit-map' do |c|
      cli_syntax(c, 'MAP_NAME [ASSET_SPEC]')
      c.description = "Edit mapping data for one or more assets"
      add_multi_node_options(c)
      c.action Commands, :'modifys-map'
    end

    command :'edit-notes' do |c|
      cli_syntax(c, '[ASSET_SPEC]')
      c.description = "Edit miscellaneous notes for one or more assets"
      add_multi_node_options(c)
      c.action Commands, :'modifys-notes'
    end

    command :list do |c|
      cli_syntax(c)
      c.description = "List all assets that have stored data"
      c.option '-g', '--group [GROUP]',
        "Optionally select assets in GROUP, specify comma-separated list for multiple groups"
      c.option '-t', '--type [TYPE]',
        "Optionally select assets in TYPE, specify comma-separated list for multiple types"
      c.action Commands, :list
    end

    command :edit do |c|
      cli_syntax(c, 'ASSET')
      c.description = "Edit stored data for an asset"
      c.action Commands, :edit
    end

    command :'list-map' do |c|
      cli_syntax(c, 'ASSET MAP_NAME INDEX')
      c.summary = "List assets stored within mapping data"
      c.description = "View asset names stored for ASSET at the specified map INDEX."
      c.action Commands, :list_map
    end

    command :show do |c|
      cli_syntax(c, '[ASSET_SPEC]')
      c.description = "Render a template for one or more assets"
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
      c.action Commands, :show
    end

    command :delete do |c|
      cli_syntax(c, '[ASSET_SPEC]')
      c.description = "Delete the stored data for one or more assets"
      add_multi_node_options(c)
      c.action Commands, :delete
    end
  end
end
