# =============================================================================
# Copyright (C) 2020-present Alces Flight Ltd.
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

require 'xdg'
require 'inventoryware/utils'

module Inventoryware
  class Config
    class << self
      def instance
        @instance ||= Config.new
      end

      def method_missing(s, *a, &b)
        if instance.respond_to?(s)
          instance.send(s, *a, &b)
        else
          super
        end
      end

      def respond_to_missing?(s)
        instance.respond_to?(s)
      end
    end

    attr_reader :yaml_dir, :templates_dir, :templates_config_path, :plugins_dir

    def initialize
      @yaml_dir = XDG::Environment.new.cache_home.join("flight/inventory")
      @templates_dir = File.expand_path('../templates', __dir__)
      @templates_config_path = File.expand_path('templates.yml', __dir__)
      @plugins_dir = File.expand_path('../plugins', __dir__)

      FileUtils.mkdir_p yaml_dir
    end

    ##
    # NOTE: The helpers directory contains ruby code for various actions.
    #       This code can not be easily substituted and seems out of
    #       place within a "config helpers dir"
    #
    #       Consider refactoring within "lib/inventoryware/utils"
    def helpers_dir
      @helpers_dir ||= File.expand_path('../../helpers', __dir__)
    end

    ##
    # NOTE: I'm not sure if this method brings any more value then
    #       the req_files method. Assumable "groups" can be special
    #       cased in the required place
    def all_files
      @all_files ||= [*req_files, 'groups']
    end

    ##
    # NOTE: It is a bit odd having req_files as a "Config" option.
    #       The `import[_hunter]` commands hard code references to
    #       these files, which implies they are not configurable
    #
    #       Consider refactoring into the import command
    def req_files
      @req_files ||= ["lshw-xml", "lsblk-a-P"]
    end

    ##
    # NOTE Similar to req_files, this does not look like a configurable
    #      option. The types defined within this key are used through
    #      out the code base
    #
    #      Consider refactoring into a constant or schema object
    def req_keys
      @req_keys ||= ['name', 'schema', 'mutable', 'type']
    end

    # @deprecated There is only ever going to be a single cluster
    # Returns 'default' for temporary fix
    def active_cluster
      'default'
    end
  end
end
