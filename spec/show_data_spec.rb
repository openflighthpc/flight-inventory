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
require 'commander'
require 'inventoryware/cli'

describe Inventoryware::Commands::Shows::Data do

  before(:each) do
    yaml_dir = Inventoryware::Config.yaml_dir
    p yaml_dir
    Dir[yaml_dir + "/*"].each { |p| p p }
    backup_dir = File.join(File.dirname(yaml_dir), 'store_backup')
    p backup_dir
    FileUtils.mv(yaml_dir, backup_dir, :force => true)
    FileUtils.mkdir(yaml_dir)

    parse = Inventoryware::Commands::Parse.new(
       argv = [File.join(Inventoryware::Config.root_dir, 'spec/fixtures/test_example.zip')],
       options = Commander::Command::Options.new()
    )
    parse.run()
  end

  after(:each) do
    yaml_dir = Inventoryware::Config.yaml_dir
    p "#{yaml_dir}_backup"
    FileUtils.mv("#{yaml_dir}_backup", yaml_dir, :force => true)
  end

  describe "#run" do
    context "specified on a node that exists" do

      let(:out_start) { "---\ntest_example:\n  name: test_example\n  mutable:" }

      subject do
        Inventoryware::Commands::Shows::Data.new(
           argv = ['test_example'],
           options = Commander::Command::Options.new()
        )
      end
      it "returns that node's data" do
        expect { subject.run }.to output(/#{out_start}/).to_stdout
      end
    end

    context "specified on a node that doesn't exist" do

      let(:out_start) { "No files found for 'node_that_does_not_exist" }

      subject do
        Inventoryware::Commands::Shows::Data.new(
           argv = ['node_that_does_not_exist"'],
           options = Commander::Command::Options.new()
        )
      end
      it "returns that node's data" do
        expect { subject.run }.to raise_error(
          Inventoryware::ArgumentError,
          'Please refine your search'
        )
      end
    end
  end
end
