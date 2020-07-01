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
  Generator = Struct.new(:ssh) do
    def self.open(host)
      Net::SSH.start(host, 'root') do |ssh|
        gen = new(ssh)
        begin
          yield gen if block_given?
        ensure
          ssh.exec!("rm -f #{gen.remote_zip_path}")
          ssh.exec!("rm -f #{gen.remote_binary_path}")
        end
      end
    end

    attr_reader :start_zips

    def initialize(*_)
      super
      @start_zips = list_zips
    end

    def scp
      @scp ||= Net::SCP.new(ssh)
    end

    def source_binary
      return Config.generate_binary_path if File.exists? Config.generate_binary_path
      raise InternalError, <<~ERROR.chomp
        Could not locate the generate binary. Please contact your system administrator for further assistance.
        Expected Path: #{Config.generate_binary_path}
      ERROR
    end

    def list_zips
      ssh.exec!('ls /tmp/*\.zip 2>/dev/null').chomp.split("\n")
    end

    def remote_binary_path
      @remote_binary_path ||= ssh.exec!('mktemp /tmp/generate.XXXXXXXX')
                                 .chomp
                                 .tap { |p| scp.upload!(source_binary, p) }
    end

    def end_zips
      @end_zips ||= begin
        generate_output # Ensure the zip file has been created first
        list_zips
      end
    end

    def generate_output
      @generate_output ||= ssh.exec!("bash #{remote_binary_path}").chomp
    end

    def remote_zip_path
      @remote_zip_path ||= begin
        zips = end_zips - start_zips
        if zips.length == 0 && start_zips.length > 0
          raise InternalError, <<~ERROR.chomp
            Could not determine the newly created zip! Please remove the following remote files and try again:
            #{start_zips.join("\n")}
          ERROR
        elsif zips.length == 0
          raise InternalError, <<~ERROR.chomp
            Failed to generate the zip! The command returned:
            #{generate_output}
          ERROR
        elsif zips.length == 1
          zips.first
        else
          raise InternalError, <<~ERROR.chomp
            Detected multiple new zip files! This is likely due to other jobs running on the remote machine. Please remove the following zips and try again later:
            #{zips.join("\n")}
          ERROR
        end
      end
    end

    def download_zip(path)
      scp.download!(remote_zip_path, path)
    end
  end
end

