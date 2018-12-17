module Inventoryware
  class Command
    def initialize(argv, options)
      @argv = argv.freeze
      @options = OpenStruct.new(options.__hash__)
    end

    # this wrapper is here to later enable error handling &/ logging
    def run!
      run
    rescue Exception => e
      #handle_fatal_error(e)
      raise e
    end

    def run
      raise NotImplementedError
    end
  end
end
