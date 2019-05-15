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

module Inventoryware
  module Commands
    module Cluster
      class List < Command
        def run
          clusters = get_list_of_clusters

          clusters.each do |cluster|
            puts cluster
          end
        end

        private

        def get_list_of_clusters
          Dir.glob(File.join(Config.root_dir, 'var/store/*')).select { |e|
            File.directory? e
          }.map { |dir|
            File.basename(dir)
          }.map { |cluster|
            if cluster == Config.active_cluster
              "* #{cluster}"
            else
              cluster
            end
          }.sort
        end
      end
    end
  end
end
