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
require 'inventoryware/utils'

module Inventoryware
  module Commands
    module Cluster
      class Switch < Command
        def run
          cluster_config_path = Config.cluster_config_path
          cluster_config = Utils.load_yaml(cluster_config_path)
          cluster = @argv.first

          if cluster_exists?(cluster)
            cluster_config["active_cluster"] = cluster
            Utils.save_yaml(cluster_config_path, cluster_config)

            puts "'#{cluster}' is now the active cluster"
          else
            puts "'#{cluster}' is not an existing cluster"
          end
        end

        private

        def cluster_exists?(cluster)
          Dir.exist?(File.join(Config.root_dir, 'var/store', cluster))
        end
      end
    end
  end
end
