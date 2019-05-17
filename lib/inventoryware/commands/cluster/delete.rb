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

require 'fileutils'

module Inventoryware
  module Commands
    module Cluster
      class Delete < Command
        def run
          cluster = @argv.first

          prompt = TTY::Prompt.new
          unless prompt.no?("Are you sure you want to delete '#{cluster}'?")
            unless cluster == Config.active_cluster
              puts "Cluster '#{cluster}' has been deleted" if delete_cluster(cluster)
            else
              puts "Can't delete the current cluster, please switch cluster first"
            end
          end
        end

        private

        def delete_cluster(cluster)
          cluster_path = File.join(Config.root_dir, 'var/store', cluster)
          FileUtils.rm_rf(cluster_path, secure: true)
        end
      end
    end
  end
end
