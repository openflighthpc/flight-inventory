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
require 'inventoryware/exceptions'

module Inventoryware
  module Utils
    def self.check_zip_exists?(path)
      (File.file?(path) && check_zip?(path))
    end

    def self.check_zip?(path)
      File.extname(path) == ".zip"
    end

    def self.check_file_writable?(path)
      return false unless check_file_location?(path)
      return false if File.exist?(path) and not File.writable?(path)
      return true
    end

    def self.check_file_readable?(path)
      return false unless check_file_location?(path)
      return false unless File.exists?(path)
      return false unless File.readable?(path)
      return true
    end

    def self.check_file_location?(path)
      return false if File.directory?(path)
      return false unless File.directory?(File.dirname(path))
      return false if File.exists?(path) and not File.readable?(path)
      return true
    end

    # raise an error if given path isn't a directory
    def self.exit_unless_dir(path)
      unless File.directory?(path)
        raise FileSysError, <<-ERROR.chomp
Directory #{File.expand_path(path)} not found.
Please create it before continuing"
        ERROR
      end
      return true
    end

    # return a single file from glob, print error if >/< than 1 found
    def self.find_file(search_val, dir)
      results = Dir.glob(File.join(dir, "#{search_val}*"))
        if results.empty?
          $stderr.puts "No files found for '#{search_val}' in #{File.expand_path(dir)}"
        elsif results.length > 1
          file_names = results.map { |p| File.basename(p, File.extname(p)) }
          # if the results include just the search val, return that path
          if file_names.include?(search_val)
            return results.select { |p| p[/#{search_val}\..*$/] }
          end
          $stderr.puts "Ambiguous search term '#{search_val}' - possible results are:"
          file_names.each_slice(3).each { |p| $stderr.puts p.join("  ") }
        end
      return results
    end

    def self.get_new_asset_type
      type = ''
      while type.empty?
        type = $terminal.ask('Enter the type of the new assets being created')
      end
      return type
    end

    def self.load_yaml(path)
      data = nil
      begin
        File.open(path) do |f|
          data = YAML.safe_load(f)
        end
      rescue Psych::SyntaxError
        raise ParseError, <<-ERROR.chomp
Error parsing yaml in #{path} - aborting
        ERROR
      end
      return data
    end

    # retrieves all .yaml files in the storage dir
    def self.find_all_nodes()
      node_locations = Dir.glob(File.join(Config.yaml_dir, '*.yaml'))
      if node_locations.empty?
        $stderr.puts "No asset data found "\
          "in #{File.expand_path(Config.yaml_dir)}"
      end
      return node_locations
    end

    # retreives all nodes in the given groups
    # this quite an intensive method of way to go about searching the yaml
    # each file is converted to a sting and then searched
    # seems fine as it stands but if speed becomes an issue could stand to
    #   be changed
    def self.find_nodes_in_groups(groups)
      nodes = []
      find_all_nodes().each do |location|
        found = []
        File.open(location) do |file|
          contents = file.read
          m = contents.match(/primary_group: (.*?)$/)
          found.append(m[1]) if m
          m = contents.match(/secondary_groups: (.*?)$/)
          found = found + (m[1].split(',')) if m
        end
        unless (found & groups).empty?
          nodes.append(location)
        end
      end
      if nodes.empty?
        $stderr.puts "No assets found in #{groups.join(' or ')}."
      end
      return nodes
    end
  end
end
