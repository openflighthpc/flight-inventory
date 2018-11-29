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

lib_dir = File.dirname(__FILE__)
ENV['BUNDLE_GEMFILE'] ||= File.join(lib_dir, '..', 'Gemfile')

require 'rubygems'
require 'bundler'

if ENV['INVWARE_DEBUG']
  Bundler.setup(:default, :development)
  require 'pry-byebug'
else
  Bundler.setup(:default)
end

require_relative 'cli'
require_relative 'extensions/lshw'
require 'zip'
require 'tmpdir'

def check_data_source?(data_source)
  !(File.file?(data_source) && File.extname(data_source) == ".zip")
end

begin
  dir = Dir.mktmpdir('inv_ware_')
  tmp_lshw_xml = File.join(dir, 'lshw_xml')

  # Parse arguments
  options = MainParser.parse(ARGV)

  data_source = options['data_source']
  node = options['node']
  hash = {}
  hash[node] = {}

  if check_data_source?(data_source)
    puts "Error with data source #{data_source}"\
         "- must be zip file"
    exit
  end

  Zip::File.open(data_source) do |zip_file|
    zip_file.each do |entry|
      puts "Extracting #{entry.name}"
    end
    zip_file.glob('lshw-xml.txt').first.extract(tmp_lshw_xml)
    #lsbik_file = zip_file.glob('lsbik.txt').first
  end

  #TODO sort error conditions here
  f = File.open(tmp_lshw_xml)
  lshw = Lshw::XML(f)
  f.close

  hash[node]['Hardware Type'] = lshw.product

  hash[node]['System Serial Number'] = lshw.serial

  hash[node]['cpus'] = {}
  lshw.cpus.each do |cpu|
    hash[node]['cpus'][cpu.id] = {}
    hash[node]['cpus'][cpu.id]['product'] = cpu.product
    hash[node]['cpus'][cpu.id]['slot'] = cpu.slot
  end

  total_memory = 0
  lshw.all_memory.each do |mem|
    mem.banks.each do |bank|
      total_memory += bank.size
    end
  end
  hash[node]['Total Memory'] = total_memory

  lshw.all_networks.each do |net|
    hash[node][net.logical_name] = {"serial"=>net.mac}
  end
  puts hash
ensure
  FileUtils.remove_entry dir
end
