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

# Schema 0 is an edge case.
# While it designates data files from before the introduction of schemas as a
# notion, it is what is returned when any file that doesn't have a given schema
# number (nil => 0). Due to this we must detect if the file in question is a
# valid file from inventoryware version 1.2.0 or before OR if it is a file in
# an unknown state.
# We will detect this by checking the presence of a single primary key with a
# 'name' subkey. If this is the state of the file we will treat
# it as a "true" schema 0 file and proceed. Otherwise we will error.
def schema_0(asset)
  p "Attempting to update asset '#{asset.name}' from no schema to schema 1"
  unless true_schema_0?(asset)
    raise "Asset '#{asset.name}' is in an unknown state - aborting"
  end

  new_data = asset.data.values[0]

  new_data['mutable'] ||= {}
  new_data['schema'] = 1
  unless new_data['type']
    p "Setting asset '#{asset.name}' to type 'server'"
    new_data['type'] ||= 'server'
  end

  asset.data = new_data
  asset.save
  p "Successful in updating asset '#{asset.name} to schema 1"
end

def true_schema_0?(asset)
  #check for a primary key
  return false unless asset.data.keys.length == 1
  #check that the nested hash is valid & hash a name
  return false unless asset.data.values[0]['name']
  return true
end
