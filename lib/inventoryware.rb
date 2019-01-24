#!/usr/bin/env ruby
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

lib_dir = File.dirname(__FILE__)
ENV['BUNDLE_GEMFILE'] ||= File.join(lib_dir, '..', 'Gemfile')

require 'rubygems'
require 'bundler'

if ENV['INVWARE_DEBUG']
  Bundler.setup(:default, :development)
  require 'pry-byebug'
else
  Bundler.setup(:default)
end

require 'require_all'

require_rel 'command'
require_rel 'erb_utils'
require_rel 'exceptions'
require_rel 'commands/**/*.rb'
require_rel 'lsblk_parser'
require_rel 'utils'

require 'commander/import'
require 'ostruct'
require 'yaml'

module Inventoryware
  LIB_DIR = File.dirname(__FILE__)
  STORE_DIR = File.join(LIB_DIR, '../store')
  YAML_DIR = File.join(STORE_DIR, 'yaml')
  RENDERS_DIR = File.join(STORE_DIR, 'renders')
  REQ_FILES = ["lshw-xml", "lsblk-a-P"]
  OTHER_FILES = ["groups"]
  ALL_FILES = REQ_FILES + OTHER_FILES

  program :name, 'Inventoryware'
  program :version, '1.0.0'
  program :description, 'Parser of hardware information into unified formats.'

  # Display the help if there is no input arguments
  ARGV.push '--help' if ARGV.empty?

  def self.action(command, klass)
    command.action do |args, options|
      klass.new(args, options).run!
    end
  end

  def self.cli_syntax(command, args_str = '')
    s = "Inventoryware #{command.name} #{args_str} [options]"
    command.syntax = s
  end

  def self.add_node_options(command)
    command.option '--all', "Render all data in #{File.expand_path(YAML_DIR)}"
    command.option '-g', '--group GROUP',
      "Render all nodes in GROUP, commma-seperate values for multiple groups"
    return command
  end

  command :parse do |c|
    cli_syntax(c, 'DATA_SOURCE')
    c.description = 'Parse hardware information into yaml'
    action(c, Commands::Parse)
  end

  command :render do |c|
    cli_syntax(c, 'TEMPLATE NODE(S)')
    c.description = "Render nodes' data as an eRuby template"
    c.option '-l', '--location LOCATION',
      "Output the rendered template to the specified location."
    c = add_node_options(c)
    action(c, Commands::Render)
  end

  command :modify do |c|
    cli_syntax(c)
    c.description = 'Change mutable node data'
    c.sub_command_group = true
  end

  command :'modify other' do |c|
    cli_syntax(c, 'FIELD=VALUE NODE(S)')
    c.description = "Modify some nodes' data"
    c.hidden = true
    c = add_node_options(c)
    action(c, Commands::Modifys::Other)
  end

  command :'modify location' do |c|
    cli_syntax(c, 'NODE(S)')
    c.description = "Specify some nodes' location - can also be "\
      "achieved through modify"
    c.hidden = true
    c = add_node_options(c)
    action(c, Commands::Modifys::Location)
  end

  command :'modify groups' do |c|
    cli_syntax(c, 'GROUP NODE(S)')
    c.description = "Modify nodes' groups"
    c.hidden = true
    c = add_node_options(c)
    c.option '-p', '--primary', "Modify the nodes' primary groups"
    c.option '-r', '--remove', "Remove the nodes from this group"
    action(c, Commands::Modifys::Groups)
  end

  command :list do |c|
    cli_syntax(c)
    c.description = 'List stored data'
    c.sub_command_group = true
  end

  command :'list nodes' do |c|
    cli_syntax(c)
    c.description = "List all nodes the system is maintaining .yaml data on"
    action(c, Commands::Lists::Nodes)
  end

  command :'list renders' do |c|
    cli_syntax(c)
    c.description = "List all filled templates the system has stored"
    action(c, Commands::Lists::Renders)
  end

  command :show do |c|
    cli_syntax(c)
    c.description = "View stored files"
    c.sub_command_group = true
  end

  command :'show node' do |c|
    cli_syntax(c, 'NODE')
    c.description = "View the .yaml for a node"
    action(c, Commands::Shows::Node)
  end

  command :'show render' do |c|
    cli_syntax(c, 'RENDER')
    c.description = "View a rendered template"
    action(c, Commands::Shows::Render)
  end

  command :delete do |c|
    cli_syntax(c)
    c.description = "Delete stored files"
    c.sub_command_group = true
  end

  command :'delete node' do |c|
    cli_syntax(c, 'NODE')
    c.description = "Delete the .yaml for a node"
    action(c, Commands::Deletes::Node)
  end

  command :'delete render' do |c|
    cli_syntax(c, 'RENDER')
    c.description = "Delete a rendered template"
    action(c, Commands::Deletes::Render)
  end
end
