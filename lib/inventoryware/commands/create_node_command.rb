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

require 'nodeattr_utils'
require 'tempfile'
require 'tty-editor'

module Inventoryware
  module Commands
    class SingleNodeCommand < Command
      def run
        name = @argv[0]
        # error to prevent confusion if attempting to provide >1 node
        if NodeattrUtils::NodeParser.expand(name).length > 1
          raise ArgumentError, <<-ERROR.chomp
Issue with argument name, please only provide a single node
          ERROR
        end

        if @options.create
          location = File.join(Config.yaml_dir, "#{name}.yaml")
          node_data = Utils::read_node_or_create(location)
        else
          found = Utils::find_file(name, Config.yaml_dir)
          unless found.length == 1
            raise ArgumentError, <<-ERROR.chomp
Please refine your search
            ERROR
          end
          location = found[0]
          node_data = Utils::read_node_yaml(location)
        end

        action(node_data, location)
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
