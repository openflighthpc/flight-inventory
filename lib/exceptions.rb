
module Inventoryware
  class InventorywareError < RuntimeError; end

  class FileSysError < InventorywareError; end
  class ArgumentError < InventorywareError; end
end
