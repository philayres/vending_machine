# All of the products that a vending machine holds for sale
# This provides the interface for a person maintaining the vending machine 
# to load new products
# Individual product lines (identified by 'code') can be referenced directly
# through an index on this products_object[code]


require 'product'

class Products
  attr_accessor :products
  
  def initialize
    # each product appears once in the list, and maintains its own availability
    @products = []
  end
  
  def [] code    
    find_by_code code    
  end
  
  def list
    @products
  end
  
  def dispense code
    self[code].dispense
  end
  
  def available?
    available > 0
  end
  
  
  def create_product product, name=nil, price=nil, number=0
    if product.is_a? Product
      p = product 
    else
      p = Product.new(product, name, price, number)
    end
    
    throw "product with this code already exists" if find_by_code(p.code)
    
    @products << p
    return p
  end
  
  def add_items code, num
    self[code].add_items num 
  end

  def available
    self[@selected_product].available
  end
  
  def find_by_code product
    code = product
    code = product.code if product.is_a? Product
    @products.select{|p| p.code == code}.first
  end
end
