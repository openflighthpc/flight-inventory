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

require 'net/ssh'
require 'net/scp'

module Inventoryware
  module Commands
    class Generate < Command
      def run
        # Confirm the generate binary exists
        unless File.exists? Config.generate_binary_path
          raise InternalError, <<~ERROR.chomp
            Could not locate the generate binary. Please contact your system administrator for further assistance.
            Expected Path: #{Config.generate_binary_path}
          ERROR
        end

        with_connection do |ssh|
          with_scp_binary(ssh) do |path|
            zip_path =  created_zip(ssh) { ssh.exec! "bash #{path}" }
            begin
              # noop
            ensure
              ssh.exec! "rm -f #{zip_path}"
            end
          end
        end
      end

      def with_connection
        Net::SSH.start(hostname, 'root') do |ssh|
          yield ssh if block_given?
        end
      end

      # Extracts the hostname from argv
      def hostname
        argv.first
      end

      private

      def with_scp_binary(ssh)
        # Copies the generate binary to a tmp file
        tmp_path = (ssh.exec! 'mktemp /tmp/generate.XXXXXXXX').chomp
        Net::SCP.new(ssh).upload!(Config.generate_binary_path, tmp_path)
        yield tmp_path if block_given?
      ensure
        ssh.exec! "rm -f #{tmp_path}" if tmp_path
      end

      def created_zip(ssh)
        start_zips = ssh.exec!('ls /tmp/*\.zip 2>/dev/null').chomp.split("\n")
        yield if block_given?
        end_zips = ssh.exec!('ls /tmp/*\.zip 2>/dev/null').chomp.split("\n")
        new_zips = end_zips - start_zips
        if new_zips.length == 0 && start_zips.length > 0
          raise InternalError, <<~ERROR.chomp
            Failed to detect the inventory for '#{hostname}'. Please remove the following remote file(s) and try again:
            #{start_zips.join("\n")}
          ERROR
        elsif new_zips.length == 0
          raise InternalError, "Failed to generate the inventory for '#{hostname}'"
        elsif new_zips.length == 1
          new_zips.first
        else
          raise InternalError, <<~ERROR.chomp
            Multiple new zip files have been detected! This is likely due to other jobs running on the machine. Please remove the following files and try again later:
            #{end_zips.join("\n")}
          ERROR
        end
      end
    end
  end
end

