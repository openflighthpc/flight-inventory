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

require 'tempfile'
require 'tty-editor'

module Inventoryware
  module Commands
    module Modifys
      class Notes < Command
        def run
          search = Proc.new do |val|
            Dir.glob(File.join(YAML_DIR, "#{val}*.*"))
          end
          found = Utils::find_file(@argv[0], &search)

          if found
            node_data = Utils::read_node_yaml(found)
            notes = node_data['mutable'].fetch('notes', '')
            tmp_file = Tempfile.new('inv_ware_file_')
            begin
              TTY::Editor.open(tmp_file.path, content: notes, command: :rvim)
              node_data['mutable']['notes'] = tmp_file.read
            ensure
              tmp_file.close
              tmp_file.unlink
            end
            Utils::output_node_yaml(node_data, found)
          end
        end
      end
    end
  end
end
