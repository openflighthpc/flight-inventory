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

require 'xmlhasher'
require 'zip'

module Inventoryware
  module Commands
    class Parse < Command
      def run
        unless @argv.length() == 1
          raise ArgumentError, <<-ERROR.chomp
The data source should be the only argument.
          ERROR
        end

        XmlHasher.configure do |config|
          config.snakecase = true
          config.ignore_namespaces = true
          config.string_keys = true
        end

        begin
          top_dir = Dir.mktmpdir('inv_ware_')

          # get all zips in in the source, if it's a dir or not
          top_lvl_zip_paths = expand_dir(@argv[0])

          # for each of these, extract to /tmp/
          top_lvl_zip_paths.each { |zip_path| extract_zip(zip_path, top_dir) }

          # extract any zips in these zips
          recursively_extract_zips(top_dir)

          # remove empty file paths from the tmp dir
          clean_dir(top_dir)

          # parse the extracted files to yaml
          process_container_dir(top_dir)
        ensure
          FileUtils.remove_entry top_dir
        end
      end

      private
      def expand_dir(data_source)
        contents = []
        if File.directory?(data_source)
          contents = Dir.glob(File.join(data_source, "**/*.zip"))
        elsif Utils::check_zip_exists?(data_source)
          contents = [data_source]
        end
        if contents.empty?
          raise ArgumentError, <<-ERROR.chomp
No .zip files found at #{data_source}
          ERROR
        end
        return contents
      end

      def recursively_extract_zips(target_dir)
        things_changed = false
        Dir[File.join(target_dir, '**/*.zip')].each do |zip_path|
          extract_zip(zip_path, target_dir)
          File.delete(zip_path)
          things_changed = true
        end
        recursively_extract_zips(target_dir) if things_changed
      end

      def extract_zip(zip_path, destination)
        Zip::File.open(zip_path) do |zip_file|
          zip_name = File.basename(zip_file.name, '.zip')
          zip_file.each do |item|
            item_path = File.join(destination, zip_name, item.name)
            FileUtils.mkdir_p(File.dirname(item_path))
            zip_file.extract(item, item_path) unless File.exist?(item_path)
          end
        end
      end

      def clean_dir(dir)
        # A bit of a hack to delete all directories with no files in them.
        # By globbing then reversing the order you get a reversed-BFS.
        # So all directories' items will preceded the directories themselves
        # while being processed, allowing sequential deletion of empty dirs.
        dir_items = Dir.glob(File.join(dir, "**/*"))
        dir_items.reverse!
        dir_items.each do |item|
          if File.directory?(item) and Dir.empty?(item)
            FileUtils.remove_dir(item)
          end
        end
      end

      def process_container_dir(dir)
        Dir.foreach(dir) do |item|
          next if item == '.' or item == '..'
          if File.directory?(File.join(dir, item))
            process_dir(File.join(dir, item))
          end
        end
      end

      def process_dir(dir)
        node_name = File.basename(dir)
        puts "Importing #{node_name}.zip"

        invalid = false
        file_locations = {}
        ALL_FILES.each do |file|
          file_locations[file] = Dir.glob(File.join(dir, "#{file}*"))&.first
          if not file_locations[file] and REQ_FILES.include?(file)
            $stderr.puts "Warning: File #{file} required in #{node_name}.zip but not found."
            invalid = true
          end
        end

        if invalid
          puts "Skipping #{node_name}.zip"
          return false
        end

        node_data = {}
        node_data['name'] = node_name
        node_data['mutable'] = {}
        if file_locations['groups']
          node_data['mutable'] = YAML.load(File.read(file_locations['groups']))
        end
        # extract data from lshw
        node_data['lshw'] = XmlHasher.parse(File.read(file_locations['lshw-xml']))
        # extract data from lsblk
        node_data['lsblk'] = LsblkParser.new(file_locations['lsblk-a-P']).hashify()

        Utils::exit_unless_dir(YAML_DIR)
        yaml_out_name = "#{node_name}.yaml"
        out_file = File.join(YAML_DIR, yaml_out_name)

        if Utils::check_file_readable?(out_file)
          old_data = Utils::read_node_yaml(out_file)
          # NB: this prioritses 'node_data' - new values will override old ones
          node_data = merge_recursively(old_data, node_data)
        end

        Utils::output_node_yaml(node_data, out_file)

        puts "#{node_name}.zip imported to #{File.expand_path(out_file)}"
      end

      #TODO test this method with distinct & deep hashes
      def merge_recursively(a, b)
        a.merge(b) do |key, a_item, b_item|
          if a_item.is_a?(Hash) and b_item.is_a?(Hash)
            merge_recursively(a_item, b_item)
          else
            b_item
          end
        end
      end
    end
  end
end
