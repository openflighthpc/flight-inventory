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

require 'fileutils'

def migrate_to_schema_3(asset)
  create_default_directory_if_necessary

  if File.dirname(asset.path) == store_dir
    move_asset_to_default_dir(asset)
  end
end

private

def create_default_directory_if_necessary
  unless Dir.exist? default_dir
    FileUtils.mkdir(default_dir)
  end
end

def move_asset_to_default_dir(asset)
  filename = File.basename(asset.path)
  asset.move(File.join(default_dir, filename))
end

def default_dir
  File.join(store_dir, 'default')
end

def store_dir
  File.join(Inventoryware::Config.root_dir, 'var/store')
end
