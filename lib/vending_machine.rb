# A vending machine object represents the interface for a customer, whose interactions
# will all be handled through here
# A person maintaining the machine will interact with the Products / Product and CoinHolder / CoinHolder
# in order to setup products and reload them, and top up coins

require 'coin_holders'
require 'product'

class VendingMachine
  attr_accessor :products, :selected_product, :coin_holders
  
  def initialize
    @coin_holders = CoinHolders.new
    @products = Products.new
    @selected_product = nil
  end
  
  # select the product, before or after coins have been entered into the machine
  def select_product code
    @selected_product = @products.find_by_code(code)
  end
  
  
  def insert_coin denom
    @coin_holders.insert_coin(denom)  
  end
  
  def return_inserted_coins
    @coin_holders.return_inserted_coins
  end
  
  def inserted_coins_value
    @coin_holders.inserted_coins_value
  end
  
  def dispense_product
    
    throw "select a product before attempting to dispense it" unless @selected_product
    change_amount =  @coin_holders.inserted_coins_value - @selected_product.price
    
    # in reality we should not have got to this stage if any of the following fail
    # so consider them exceptions, rather than friendly return codes
    throw "insufficient money inserted for product" if change_amount < 0    
    throw "can not return exact change" unless @coin_holders.can_return_exact_change?(change_amount)
    throw "selected product is not available" unless @selected_product
    
    change = @coin_holders.dispense_change
    p = @selected_product
    @selected_product.dispense
    @selected_product = nil 
    return p, change
  end
  
  def products_available 
    @products.list.reject {|p| !p.available?}
  end
  
  def product_available?
    p = @products[@selected_product]
    return nil unless p
    p.available?
  end
  
  def money_required
    return 0 if @selected_product.nil?
    @selected_product.price - inserted_coins_value
  end
  
private

  
  
end
