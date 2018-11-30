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

require 'optparse'

class MainParser
  def self.parse(args)
  options = {}
  options['pri_group'] = nil
  options['sec_groups'] = []
  options['template'] = nil

  opt_parser = OptionParser.new do |opt|
    opt.banner = "Usage inventoryware NODE DATA [GROUPS]"

    opt.on("-n", "--node NODE", "Parse data for NODE") do |node|
      options['node'] = node
    end

    opt.on("-d", "--data DATA", "Parse data from source DATA") do |data|
      options['data_source'] = data
    end

    opt.on("-p", "--primary-group PRIMARY-GROUP",
           "Assign the node to PRMIARY-GROUP") do |pri_g|
      options['pri_group'] = pri_g
    end

    opt.on("-s", "--secondary-groups LIST,OF,GROUPS", Array,
           "Assign the node groups LIST, OF and GROUPS") do |sec_g|
      options['sec_groups'] = sec_g
    end

    opt.on("-t", "--template TEMPLATE",
           "Path to desired template, if blank yaml will be output") do |templ|
      options['template'] = templ
    end

    opt.on("-h","--help","show this help screen") do
      puts opt
      exit
    end
  end

  opt_parser.parse!(args)

  if !options['node'] || !options['data_source']
    puts "Node and data source not specified"
  end

  return options
  end
end
