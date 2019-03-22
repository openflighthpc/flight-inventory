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

require 'inventoryware/config'
require 'inventoryware/exceptions'

module Inventoryware
  class TemplatesConfig
    def initialize
      @path = Config.templates_config_path
      unless File.readable?(@path)
        raise FileSysError, <<-ERROR.chomp
Template config at #{@path} is inaccessible
        ERROR
      end
    end

    def data
      @data ||= open
    end

    def open
      contents = Utils.load_yaml(@path)
      unless contents.is_a?(Hash)
        raise ParseError, <<-ERROR.chomp
Template config at #{Config.template_config_path} is in an incorrect format
        ERROR
      end
      return contents
    end

    def find(format = nil, type)
      if format
        if data.dig(format, type)
          return data[format][type]
        # if a format is specified & it doesn't exist just error
        # don't continue looking
        else
          not_found_error(format, type)
        end
      elsif data[type]
        return data[type]
      elsif data.values[0][type]
        return data.values[0][type]
      else
        not_found_error(format, type)
      end
    end

    def not_found_error(format = nil, type)
      tag = format ? "Output format '#{format}' with a": 'A'
      raise ParseError, <<-ERROR.chomp
#{tag}sset type '#{type}' is not included in template config file
      ERROR
    end
  end
end
