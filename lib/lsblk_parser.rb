# Only designed on lsblk output with the -a (all) and 
# -P (key/value pairs) options
class LsblkParser
  attr_reader :rows

  def initialize(file)
    f = File.open(file)
    f_rows = f.read.split("\n")
    f.close
    @rows = f_rows.map { |row| LsblkRow.new(row) }
  end
  
  class LsblkRow
    attr_reader :name, :type, :size

    def initialize(row)
      @row = row
      @name = find_value('NAME')
      @type = find_value('TYPE') 
      @size = find_value('SIZE')
    end

    def find_value(key)
      /#{key}="(.*?)"/.match(@row)[1]
    end
  end
end
