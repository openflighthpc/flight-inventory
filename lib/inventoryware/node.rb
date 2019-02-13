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
      node_data = nil
      begin
        File.open(@location) do |f|
          node_data = YAML.safe_load(f)
        end
      rescue Psych::SyntaxError
        raise ParseError, <<-ERROR.chomp
Error parsing yaml in #{node_location} - aborting
        ERROR
      end
      # condition for if the .yaml is empty
      unless node_data
        raise ParseError, <<-ERROR.chomp
Yaml in #{node_location} is empty - aborting
        ERROR
      end
      @data = node_data.values[0]
      return @data
    end

    def save
      unless Utils::check_file_writable?(@location)
        raise FileSysError, <<-ERROR.chomp
Output file #{@location} not accessible - aborting
        ERROR
      end
      yaml_hash = {data['name'] => data}
      File.open(@location, 'w') { |file| file.write(yaml_hash.to_yaml) }
    end

    def create_if_non_existent
      unless Utils::check_file_readable?(@location)
        @data = {
          'name' => @name,
          'mutable' => {},
        }
        save
      end
    end

    attr_reader :location, :name
  end
end
