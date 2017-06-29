# An individual product line, identified by 'code'
# The product maintains its availability
# A vending machine maintainer should not need to interact with this directly

class Product
  attr_accessor :name, :price, :code, :available
  
  def initialize code=nil, name=nil, price=nil, available=0
    @name = name
    @price = price
    @code = code
    @available = available
  end
  
  def dispense
    throw "product does not have availability" if @available < 1 
    @available -= 1
    return 1
  end
  
  def add_items number
    @available += number
  end
  
  def available?
    available > 0
  end
  
end
