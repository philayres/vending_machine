# To change this license header, choose License Headers in Project Properties.
# To change this template file, choose Tools | Templates
# and open the template in the editor.

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'vending_machine'
describe VendingMachine do
  
  it "should desc" do
    vending_machine = VendingMachine.new
    
    # create and load products
    vending_machine.products.create_product :a1, "crisps", 75, 15
    vending_machine.products.create_product :b1, "peanuts", 99, 20
    vending_machine.products.create_product :c1, "chocolate", 125, 25

    # load coins for change
    vending_machine.coin_holders.denominations.each do |c|
      vending_machine.coin_holders.add_coins c, 100
    end

    # customer buys chocolate
    vending_machine.select_product :c1
    vending_machine.insert_coin :p100
    vending_machine.insert_coin :p50
    vending_machine.dispense_product
    # result is product and list of change
  end
end

