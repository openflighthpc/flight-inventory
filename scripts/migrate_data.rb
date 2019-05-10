#!/usr/bin/env ruby
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

# WILL NEED TO BE UPDATED WITH 'schema_X' METHODS FOR ANY FUTURE CHANGES
# Currently supports schema 0 (no schema) to 1

lib_dir = File.join(__FILE__, '../../lib')
$LOAD_PATH << lib_dir

require 'rubygems'
require 'bundler'

# Require every migration within scripts/migrations
Dir[File.join(__dir__, 'migrations', '*.rb')].each { |file| require file }

Bundler.setup(:default)

require 'inventoryware/cli'

def migrate_asset_schema(asset)
  changed = false
  while
    if asset.schema.to_f < Inventoryware::SCHEMA_NUM
      method_name = "schema_" + asset.schema.to_s
      unless respond_to?(method_name, true)
        raise <<-ERROR
No migration method found for schema '#{asset.schema}' (for asset '#{asset.name}').
This script cannot solve this issue.
Please edit the asset's file, delete it or expand this script before continuing.
Aborting.
        ERROR
      end
      send(method_name, asset)
      changed = true
    else
      p "No changes needed for asset '#{asset.name}' - at schema #{asset.schema}"
      changed = false
    end
    break unless changed
  end
  asset.save
end

# To process all files
if ARGV.empty?
  Dir.glob(File.join(Inventoryware::Config.yaml_dir, '*.yaml')).each do |p|
    migrate_asset_schema(Inventoryware::Node.new(p))
  end
# To process a specific file
else
  path = if File.file?(ARGV.first)
          ARGV.first
         else
           File.join(Inventoryware::Config.yaml_dir, ARGV.first + ".yaml")
         end
  migrate_asset_schema(Inventoryware::Node.new(path))
end
