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

lib_dir = File.join(__FILE__, '../../lib')
scripts_dir = File.join(__FILE__, '../')
$LOAD_PATH << lib_dir

require 'rubygems'
require 'bundler'

Bundler.setup(:default)

require 'inventoryware/cli'

# To process all files
if ARGV.empty?
  assets = Dir.glob(File.join(Inventoryware::Config.yaml_dir, '*.yaml')).map do |p|
    Inventoryware::Node.new(p)
  end

  changed = true
  while !assets.empty? and changed
    changed = false
    assets.each do |asset|
      migrate_asset(asset)
      unless asset.schema.to_f < Inventoryware::SCHEMA_NUM
        changed = true
        assets.delete(asset)
      end
    end
  end
# To process a specific file
else
  path = if File.file?(ARGV[0])
           ARGV[0]
         else
           File.join(Inventoryware::Config.yaml_dir, ARGV[0] + ".yaml")
         end
  migrate_asset(Inventoryware::Node.new(path))
end
