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

describe Inventoryware::Commands::Modifys::Other do

  before(:each) do
    yaml_dir = Inventoryware::Config.yaml_dir
    FileUtils.mv(yaml_dir, "#{yaml_dir}_backup", :force => true)
    FileUtils.mkdir(yaml_dir)

    parse = Inventoryware::Commands::Parse.new(
       argv = [File.join(Inventoryware::Config.root_dir, 'spec/fixtures/test_example.zip')],
       options = Commander::Command::Options.new()
    )
    parse.run()
  end

  after(:each) do
    yaml_dir = Inventoryware::Config.yaml_dir
    FileUtils.mv("#{yaml_dir}_backup", yaml_dir, :force => true)
  end

  describe "#run" do
    context "given a valid modification" do

      let(:out_mid) { "a: b\n  lshw" }

      subject do
        Inventoryware::Commands::Modifys::Other.new(
           argv = ['a=b', 'test_example'],
           options = Commander::Command::Options.new()
        )
      end
      it "returns that node's data" do
        subject.run()
        file = File.open(File.join(Inventoryware::Config.yaml_dir, 'test_example.yaml'))
        contents = file.read
        expect(contents).to match(/#{out_mid}/)
      end
    end

    context "given more than one node" do
    end

    context "given the --all flag" do
    end

    context "given a --group option" do
    end
  end
end