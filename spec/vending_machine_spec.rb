# Specify how a customer shall use a vending machine

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'vending_machine'

describe VendingMachine do
  before(:each) do
    
    @vending_machine = VendingMachine.new
    @product = build(:product)
    p = @vending_machine.products.create_product @product
    p.add_items(21)
    
    @product2 = build(:product)
    @product2.code = 144
    @product2.name = "peanuts"
    @product2.price = 87
    p = @vending_machine.products.create_product @product2
    p.add_items(2)
    
    # fill the coins following a factory template
    # coin_holders_spec provides more interface / interaction friendly
    # approaches for loading coins
    cs = build(:coin_holders)
    cs.each do |c|
      @vending_machine.coin_holders.add_coins(c.denom, c.available)
    end
  end

  it "accepts a coin" do
    @vending_machine.insert_coin(:p1)
    @vending_machine.insert_coin(:p2)
    @vending_machine.insert_coin(:p50)
    @vending_machine.insert_coin(:p100)
    
    expect(@vending_machine.inserted_coins_value).to eq 153
  end
  
 
  it "cancels a request and returns coins" do
    @vending_machine.insert_coin(:p1)
    @vending_machine.insert_coin(:p2)
    @vending_machine.insert_coin(:p50)
    @vending_machine.insert_coin(:p100)
    expect(@vending_machine.return_inserted_coins).to eq([
      {denom: :p1, number: 1}, 
      {denom: :p2, number: 1}, 
      {denom: :p50, number: 1}, 
      {denom: :p100, number: 1}
    ])
  end
  
  it "checks if sufficient coins have been inserted for a selected product, or how much more is needed otherwise" do
    @vending_machine.select_product(155)
    
    expect(@vending_machine.selected_product.price).to eq 74
    
    expect(@vending_machine.money_required).to eq 74
    
    @vending_machine.insert_coin(:p20)
    expect(@vending_machine.money_required).to eq 54
    
    @vending_machine.insert_coin(:p50)
    expect(@vending_machine.money_required).to eq 4
    
    @vending_machine.insert_coin(:p10)
    expect(@vending_machine.money_required).to eq -6
  end
  
  it "checks if change is required and can be returned" do
    @vending_machine.select_product(155)
    
    @vending_machine.insert_coin(:p100)
    expect(@vending_machine.money_required).to eq -26
    
    expect(@vending_machine.coin_holders.can_return_exact_change?(26)).to be true
    
    @vending_machine.coin_holders[:p1].available = 0
    @vending_machine.coin_holders[:p2].available = 0
    @vending_machine.coin_holders[:p5].available = 0
    expect(@vending_machine.coin_holders.can_return_exact_change?(26)).to be false
    
    
  end
  
  it "informs customer if the product can not be delivered due to it be unavailable (error case)" do
    @vending_machine.select_product(155)
    expect(@vending_machine.product_available?).to be true
    
    # expect it to be nil if the product line does not exist
    @vending_machine.select_product(156)
    expect(@vending_machine.product_available?).to be nil
    
    @vending_machine.products.create_product(156, "chocolate bar", 123)
    expect(@vending_machine.product_available?).to be nil
    
    
  end
  
  
  it "delivers the product (and updates those available) and returns change" do
    @vending_machine.select_product(155)
    
    @vending_machine.insert_coin(:p100)
    expect(@vending_machine.money_required).to eq -26
    expect(@vending_machine.coin_holders.can_return_exact_change?(26)).to be true
    
    product, change = @vending_machine.dispense_product
    expect(product.code).to eq 155
    expect(change).to eq([
      {denom: :p1, number: 1, value: 1}, 
      {denom: :p5, number: 1, value: 5 }, 
      {denom: :p20, number: 1, value: 20}
    ])
    
  end
  
  it "runs out of a product" do
    
    @vending_machine.select_product(144)
    @vending_machine.insert_coin(:p100)
    product, change = @vending_machine.dispense_product
    
    @vending_machine.select_product(144)
    @vending_machine.insert_coin(:p100)
    product, change = @vending_machine.dispense_product
    
    expect(@vending_machine.products_available.map(&:code)).to include 155
    expect(@vending_machine.products_available.map(&:code)).not_to include 144
  end
end

