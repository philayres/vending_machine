Vending Machine
===

A Ruby implementation of a vending machine.

A customer interacts with an instance of a VendingMachine (vending_machine), to
see available products, select a product, insert coins, dispense products or 
cancel and return coins.

A vending machine maintainer interacts with the vending_machine.products, (an
instance of Products) to manage product lines and add new products to be sold

A vending machine maintainer interacts with the vending_machine.coin_holders,
(an instance of CoinHolders) to manage the coins to be used for change

Installation
---

Setup with bundler

    bundle install

Run the spec tests

    rspec

Specs should provide a reasonable view of the interface and its usage. With more
time, specs could be cleaned up to document usage even more clearly.

Sample
---

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



Licence
---

Copyright Phil Ayres - phil.ayres@consected.com