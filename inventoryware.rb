#!/usr/bin/env ruby
#==============================================================================
# Copyright (C) 2018 Stephen F. Norledge and Alces Software Ltd.
#
# This file/package is part of Alces inventoryware.
#
# Alces inventoryware is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# Alces inventoryware is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this package.  If not, see <http://www.gnu.org/licenses/>.
#
# For more information on Alces inventoryware, please visit:
# https://github.com/alces-software/inventoryware
#==============================================================================

require './cli'
require 'zip'

def check_data_source?(data_source)
  !(File.file?(data_source) && data_source.end_with?(".zip"))
end

begin
  # Parse arguments
  options = MainParser.parse(ARGV)

  data_source = options['data_source']

  if check_data_source?(data_source)
    puts "Error with data source #{data_source}"\
         "- must be zip file"
    exit
  end

  Zip::File.open(data_source) do |zip_file|
    zip_file.each do |entry|
      puts "Extracting #{entry.name}"
    end
    lshw_xml_file = zip_file.glob('lshw-xml').first
    lsbik_file = zip_file.glob('lsbik').first
  end
end
