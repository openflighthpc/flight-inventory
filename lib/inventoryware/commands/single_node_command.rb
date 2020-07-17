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

        # error to prevent confusion if attempting to provide >1 node
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
            raise ArgumentError, "Could not locate asset: #{name}"
          end
          node = Node.new(found[0])
        end

        node.check_schema

        action(node)
      end

      def action
        raise NotImplementedError
      end
    end
  end
end
