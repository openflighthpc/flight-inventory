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

    attr_reader :root_dir, :yaml_dir, :templates_dir, :helpers_dir, :req_files,
      :other_files, :all_files, :templates_config_path, :plugins_dir

    def initialize
      @root_dir = File.expand_path(File.join(File.dirname(__FILE__), '../..'))
      @yaml_dir = File.join(@root_dir, 'var/store')
      @templates_dir = File.join(@root_dir, 'templates')
      @helpers_dir = File.join(@root_dir, 'helpers')
      @plugins_dir = File.join(@root_dir, 'plugins')

      @templates_config_path = File.join(@root_dir, 'etc/templates.yml')

      @req_files = ["lshw-xml", "lsblk-a-P"]
      @other_files = ["groups"]
      @all_files = @req_files + @other_files
    end
  end
end
