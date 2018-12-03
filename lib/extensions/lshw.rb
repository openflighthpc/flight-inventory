require 'lshw'

module Extensions
  module Lshw
    module System
      SERIAL_PATH = '/list/node/serial'
      ALL_MEMORY_PATH = "//node[@class='memory']"
      ALL_NETWORKS_PATH = "//node[@class='network']"

      def serial
        @hw.search(SERIAL_PATH).text
      end

      def all_memory
        @hw.search(ALL_MEMORY_PATH).collect { |memory| ::Lshw::Memory.new memory }
      end

      def all_networks
        @hw.search(ALL_NETWORKS_PATH).collect { |i| ::Lshw::NetworkInterface.new i }
      end
    end
    module CPU
      def id
        @node['id']
      end
      def slot
        @node.search('./slot').text
      end
      def version
        @node.search('./version').text
      end
    end
    module NetworkInterface
      def logical_name
        @node.search('./logicalname').text
      end
    end
  end
end

Lshw::System.include Extensions::Lshw::System
Lshw::CPU.include Extensions::Lshw::CPU
Lshw::NetworkInterface.include Extensions::Lshw::NetworkInterface
