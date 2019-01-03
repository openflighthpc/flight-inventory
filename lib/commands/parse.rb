
require 'xmlhasher'
require 'tmpdir'
require 'zip'

module Inventoryware
  module Commands
    class Parse < Command
      def output_yaml(name, hash)
        exit_unless_dir(YAML_DIR)
        yaml_out_name = "#{hash['Name']}.yaml"
        out_file = File.join(YAML_DIR, yaml_out_name)
        yaml_hash = {hash['Name'] => hash}
        File.open(out_file, 'w') { |file| file.write(yaml_hash.to_yaml) }
      end

      def run
        unless @argv.length() == 1
          puts "Error: The data source should be the only argument."
          exit
        end
        data_source = @argv[0]
        # confirm data exists and is in right format (.zip)
        if not check_zip?(data_source)
          puts "Error: data source #{data_source}"\
               " - must be zip file"
          exit
        end
        begin
          #create a tmp file for each required file
          dir = Dir.mktmpdir('inv_ware_')

          file_locations = {}
          REQ_FILES.each do |file|
            file_locations[file] = File.join(dir, file)
          end

          # unzip data and extract each required file to the created tmp files
          Zip::File.open(data_source) do |zip_file|
            zip_file.each do |entry|
              puts "Extracting #{entry.name}"
            end
            if file_locations.all? { |file, v| zip_file.glob("#{file}*").first }
              file_locations.each do |file, value|
                zip_file.glob("#{file}*").first.extract(value)
              end
            else
              puts "Error: #{REQ_FILES.join(" & ")} files required in .zip but not found."
              exit
            end
          end

          XmlHasher.configure do |config|
            config.snakecase = true
            config.ignore_namespaces = true
            config.string_keys = true
          end

          hash = {}
          # The node's name is inferred from the name of the .zip
          # The second argument removes the extension
          hash['Name'] = File.basename(data_source, ".*")
          #TODO find which format the groups will be specifed in and scrub like that
          # extract data from lshw
          hash['lshw'] = XmlHasher.parse(File.read(file_locations['lshw-xml']))
          # extract data from lsblk
          hash['lsblk'] = LsblkParser.new(file_locations['lsblk-a-P']).hashify()

          output_yaml(hash['Name'], hash)
        ensure
          FileUtils.remove_entry dir
        end
      end
    end
  end
end
