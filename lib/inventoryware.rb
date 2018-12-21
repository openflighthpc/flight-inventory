#!/usr/bin/env ruby
#==============================================================================
# Copyright (C) 2018 Stephen F. Norledge and Alces Software Ltd.
#
# This file/package is part of Alces inventoryware.
#
# Alces inventoryware is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# Alces inventoryware is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this package.  If not, see <http://www.gnu.org/licenses/>.
#
# For more information on Alces inventoryware, please visit:
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
require_rel 'commands/*.rb'
require_rel 'lsblk_parser'
require_rel 'utils'

require 'commander/import'
require 'ostruct'
require 'yaml'

module Inventoryware
  LIB_DIR = File.dirname(__FILE__)
  OUTPUT_DIR = File.join(LIB_DIR, '../store')
  YAML_DIR = File.join(OUTPUT_DIR, 'yaml')
  REQ_FILES = ["lshw-xml", "lsblk-a-P"]
  OTHER_FILES = []
  ALL_FILES = REQ_FILES + OTHER_FILES

  program :name, 'Inventoryware'
  program :version, '0.0.1'
  program :description, 'Parser of hardware information into unified formats.'

  # suppress_trace_class UserError

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

  command :parse do |c|
    cli_syntax(c, 'DATA_SOURCE')
    c.description = 'Parse hardware information into yaml'
    action(c, Commands::Parse)
  end

  command :render do |c|
    cli_syntax(c, 'NODE TEMPLATE')
    c.description = "Render a node's data as an eRuby template"
    c.option '-l', '--location LOCATION',
        "Output the rendered template to the specified location"
    action(c, Commands::Render)
  end

end
