#==============================================================================
# Copyright (C) 2019-present Alces Flight Ltd.
#
# This file/package is part of Inventoryware.
#
# Inventoryware is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# Inventoryware is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this package.  If not, see <http://www.gnu.org/licenses/>.
#
# For more information on Inventoryware, please visit:
# https://github.com/openflighthpc/inventoryware
#==============================================================================

module Inventoryware
  class Config
    class << self
      def instance
        @instance ||= Config.new
      end

      def method_missing(s, *a, &b)
        if instance.respond_to?(s)
          instance.send(s)
        else
          raise
        end
      end

      def respond_to_missing?(s)
        instance.respond_to?(s)
      end
    end

    attr_reader :root_dir, :yaml_dir, :templates_dir, :helpers_dir, :req_files,
      :other_files, :all_files, :templates_config_path

    def initialize
      @root_dir = File.expand_path(File.join(File.dirname(__FILE__), '../..'))
      @yaml_dir = File.join(@root_dir, 'var/store')
      @templates_dir = File.join(@root_dir, 'templates')
      @helpers_dir = File.join(@root_dir, 'helpers')

      @templates_config_path = File.join(@root_dir, 'etc/templates.conf')

      @req_files = ["lshw-xml", "lsblk-a-P"]
      @other_files = ["groups"]
      @all_files = @req_files + @other_files
    end
  end
end
