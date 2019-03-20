#==============================================================================
# Copyright (C) 2019-present Alces Flight Ltd.
#
# This file/package is part of Inventoryware.
#
# Inventoryware is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# Inventoryware is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this package.  If not, see <http://www.gnu.org/licenses/>.
#
# For more information on Inventoryware, please visit:
# https://github.com/openflighthpc/inventoryware
#==============================================================================
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
  end
end
