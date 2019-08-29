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
require 'inventoryware/command'
require 'inventoryware/config'
require 'inventoryware/exceptions'
require 'inventoryware/lsblk_parser'
require 'inventoryware/utils'

require 'fileutils'
require 'xmlhasher'
require 'pathname'
require 'yaml'
require 'zip'

module Inventoryware
  module Commands
    class ImportHunter < Command
      def run
        unless @argv.length() == 1
          raise ArgumentError, <<-ERROR.chomp
The data source should be the only argument
          ERROR
        end

        XmlHasher.configure do |config|
          config.snakecase = true
          config.ignore_namespaces = true
          config.string_keys = true
        end

        # determine if given path is absolute
        file_name = @argv[0]
        file_path = File.expand_path(file_name)

        if file_path.nil?
          raise ArgumentError, <<-ERROR.chomp
Please refine your search and try again.
          ERROR
        else
          if not Utils.check_file_readable?(file_path)
            raise ArgumentError, <<-ERROR.chomp
Zip file at #{file_path} inaccessible.
            ERROR
          end
        end
        nodelist = Utils.load_yaml(file_path)
        nodelist.each do |key,value|
          node_name = value["hostname"]
          outyaml = YAML.load(value["payload"])
          outyaml["name"] = node_name
          node_data = outyaml

          Utils.exit_unless_dir(Config.yaml_dir)
          yaml_out_name = "#{node_name}.yaml"
          out_file = File.join(Config.yaml_dir, yaml_out_name)

          node = Node.new(out_file)
          node.data = node_data
          node.save

          puts "#{node_name} imported to #{File.expand_path(out_file)}"
        end
      end
    end
  end
end