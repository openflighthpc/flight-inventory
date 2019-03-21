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
require 'inventoryware/exceptions'
require 'inventoryware/utils'

module Inventoryware
  class Node
    def initialize(location)
      @location = location
      @name = File.basename(location, File.extname(location))
    end

    def data
      @data ||= open
    end

    def data=(value)
      @data = value
    end

    def open
      node_data = Utils.load_yaml(@location)
      # condition for if the .yaml is empty
      unless node_data
        raise ParseError, <<-ERROR.chomp
Yaml in #{@location} is empty - aborting
        ERROR
      end
      @data = node_data.values[0]
      return @data
    end

    def save
      unless Utils.check_file_writable?(@location)
        raise FileSysError, <<-ERROR.chomp
Output file #{@location} not accessible - aborting
        ERROR
      end
      yaml_hash = {data['name'] => data}
      File.open(@location, 'w') { |file| file.write(yaml_hash.to_yaml) }
    end

    def create_if_non_existent(type = '')
      unless Utils.check_file_readable?(@location)
        @data = {
          'name' => @name,
          'mutable' => {},
          'type' => type,
        }
        save
      end
    end

    attr_reader :location, :name
  end
end
