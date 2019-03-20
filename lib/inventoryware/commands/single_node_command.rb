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
require 'inventoryware/command'
require 'inventoryware/exceptions'
require 'inventoryware/node'
require 'inventoryware/utils'

require 'nodeattr_utils'
require 'tempfile'
require 'tty-editor'

module Inventoryware
  module Commands
    class SingleNodeCommand < Command
      def run
        name = @argv[0]
        # error to prevent confusion if attempting to provide >1 asset
        if NodeattrUtils::NodeParser.expand(name).length > 1
          raise ArgumentError, <<-ERROR.chomp
Issue with argument name, please only provide a single asset
          ERROR
        end

        if @options.create
          location = File.join(Config.yaml_dir, "#{name}.yaml")
          node = Node.new(location)
          node.create_if_non_existent(Utils.get_new_asset_type)
        else
          found = Utils.find_file(name, Config.yaml_dir)
          unless found.length == 1
            raise ArgumentError, <<-ERROR.chomp
Please refine your search
            ERROR
          end
          node = Node.new(found[0])
        end

        action(node)
      end

      def action
        raise NotImplementedError
      end

      def edit_with_tmp_file(text, command)
        tmp_file = Tempfile.new('inv_ware_file_')
        begin
          TTY::Editor.open(tmp_file.path,
                           content: text,
                           command: command)
          edited = tmp_file.read
        ensure
          tmp_file.close
          tmp_file.unlink
        end
        return edited
      end
    end
  end
end
