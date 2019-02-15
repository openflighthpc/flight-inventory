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

describe Inventoryware::Commands::Parse do

  before(:each) do
    yaml_dir = Inventoryware::Config.yaml_dir
    FileUtils.mv(yaml_dir, "#{yaml_dir}_backup", :force => true)
    FileUtils.mkdir(yaml_dir)
  end

  after(:each) do
    yaml_dir = Inventoryware::Config.yaml_dir
    FileUtils.mv("#{yaml_dir}_backup", yaml_dir, :force => true)
  end

  describe "#run" do
    context "not given a target location" do
      subject do
        Inventoryware::Commands::Parse.new(argv = [],
           options = Commander::Command::Options.new())
      end
      it "raises an exception" do
        expect { subject.run }.to raise_error(Inventoryware::ArgumentError,
          'The data source should be the only argument')
      end
    end

    context "given 2 arguments" do
      subject do
        Inventoryware::Commands::Parse.new(argv = ['a', 'b'],
           options = Commander::Command::Options.new())
      end
      it "raises an exception" do
        expect { subject.run }.to raise_error(Inventoryware::ArgumentError,
          'The data source should be the only argument')
      end
    end

    context "given a non-existent target location" do
      subject do
        Inventoryware::Commands::Parse.new(
           argv = [File.join(Inventoryware::Config.root_dir, 'zzzz/yyyy')],
           options = Commander::Command::Options.new()
        )
      end
      it "raises an exception" do
        expect { subject.run }.to raise_error(Inventoryware::ArgumentError,
          /No \.zip files found at/)
      end
    end

    context "given a valid target location" do
      subject do
        Inventoryware::Commands::Parse.new(
           argv = [File.join(Inventoryware::Config.root_dir, 'spec/fixtures/test_example.zip')],
           options = Commander::Command::Options.new()
        )
      end

      let(:file) { File.join(Inventoryware::Config.yaml_dir, 'test_example.yaml') }
      let(:node_data) { File.open(file) { |f| YAML.safe_load(f) }.values[0] }

      it "creates a file in the store for the node" do
        subject.run()
        expect { Dir[Inventoryware::Config.yaml_dir].to include(file) }
      end

      it "creates a file containing valid yaml" do
        subject.run()
        expect(node_data).to be_a(Hash)
      end

      it "creates a file containing lshw output" do
        subject.run()
        expect(node_data.key?('lshw')).to be true
      end

      it "creates a file containing the node's groups" do
        subject.run()
        pri_bool = (node_data['mutable']['primary_group'] == 'INAPRIGROUP')
        sec_bool = (node_data['mutable']['secondary_groups'] == 'IN,SEC,GROUPS')
        expect(pri_bool && sec_bool).to be true
      end
    end

    #TODO these
    context "given a zip without any groups" do
    end

    context "given a nested zip" do
    end

    context "given a directory of zips" do
    end
  end
end
