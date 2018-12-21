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

def check_zip_exists?(path)
  (File.file?(path) && check_zip?(path))
end

def check_zip?(path)
  File.extname(path) == ".zip"
end

def check_file_writable?(path)
  return false unless check_file?(path)
  return false if File.exists?(path) and not File.writable?(path)
  return true
end

def check_file?(path)
  return false if File.directory?(path)
  return false unless File.directory?(File.dirname(path))
  return false if File.exists?(path) and not File.readable?(path)
  return true
end

def exit_unless_dir(path)
  unless File.directory?(path)
    puts "Error: Directory #{File.expand_path(path)} not found - please create "\
      "it before continuing."
    exit
  end
  return true
end
