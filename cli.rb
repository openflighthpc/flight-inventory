require 'optparse'

class MainParser
  def self.parse(args)
  options = {}

  opt_parser = OptionParser.new do |opt|
    opt.banner = "Usage inventoryware NODE DATA [GROUPS]"
    
    opt.on("-n", "--node NODE", "Parse data for NODE") do |node|
      options['node'] = node
    end

    opt.on("-d", "--data DATA", "Parse data from DATA") do |data|
      options['data_source'] = data
    end

    opt.on("-p", "--primary-group PRIMARY-GROUP",
           "Assign the node to PRMIARY-GROUP") do |pri_g|
      options['pri_group'] = pri_g 
    end

    opt.on("-s", "--secondary-groups SECONDARY-GROUPS",
           "Assign the node groups SECONDARY-GROUPS") do |sec_g|
      options['sec_groups'] = sec_g 
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
