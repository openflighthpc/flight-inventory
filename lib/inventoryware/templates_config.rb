require 'inventoryware/config'
require 'inventoryware/exceptions'

module Inventoryware
  class TemplatesConfig
    def initialize
      @path = Config.templates_config_path
      unless File.readable?(@path)
        raise FileSysError, <<-ERROR.chomp
Template config at #{@path} is inaccessible
        ERROR
      end
    end

    def data
      @data ||= open
    end

    def open
      contents = Utils.load_yaml(@path)
      unless contents.is_a?(Hash)
        raise ParseError, <<-ERROR.chomp
Template config at #{Config.template_config_path} is in an incorrect format
        ERROR
      end
      return contents
    end

    def find(format = nil, type)
      if format
        if data.dig(format, type)
          return data[format][type]
        # if a format is specified & it doesn't exist just error
        # don't continue looking
        else
          not_found_error(format, type)
        end
      elsif data[type]
        return data[type]
      elsif data.values[0][type]
        return data.values[0][type]
      else
        not_found_error(format, type)
      end
    end

    def not_found_error(format = nil, type)
      tag = format ? "Output format '#{format}' with a": 'A'
      raise ParseError, <<-ERROR.chomp
#{tag}sset type '#{type}' is not included in template config file
      ERROR
    end
  end
end
