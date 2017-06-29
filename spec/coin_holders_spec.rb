# Specifications for managing the coins in coin holders, and how change is 
# calculated, dispensed, reloaded from deposited coins, etc

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'coin_holders'


describe CoinHolders do
  before(:each) do
    @coin_holders, @initial_coin_holders = build_pair(:coin_holders)
  end
  
  let :init_value do
    1*200 + 2*100 + 5*300 + 10*80 + 20*100 + 50*40 + 100*30 + 200*20 
  end
  
  it "sets up the coin holders successfully" do
    expect(@coin_holders).to be_a CoinHolders
  end

  it "accepts coins of certain denominations" do
    expect(@coin_holders.denominations).to eq [:p1, :p2, :p5, :p10, :p20, :p50, :p100, :p200]
  end
  
  it "accepts reload of change and tracks how much change of each denomination is held" do
    
    expect(@coin_holders[:p1].available).to eq 200
    @coin_holders.add_coins :p1, 500   
    expect(@coin_holders[:p1].available).to eq 500 + @initial_coin_holders[:p1].available
    
    expect(@coin_holders[:p100].available).to eq 30
    @coin_holders.add_coins :p100, 20
    expect(@coin_holders[:p100].available).to eq 20 + @initial_coin_holders[:p100].available
    
  end
  
  it "tracks how much change total is held" do
    
    expect(@coin_holders.total_value).to eq init_value
    
    @coin_holders.add_coins :p50, 7
    expect(@coin_holders.total_value).to eq (init_value + 7*50)
    
  end
  

  it "lists the coins to returned as change based on an amount" do
    amount_to_return = 73
    expect(@coin_holders.can_return_exact_change?(amount_to_return)).to be true
    ret = [
      {denom: :p1, number: 1, value: 1}, 
      {denom: :p2, number: 1, value: 2}, 
      {denom: :p20, number: 1, value: 20}, 
      {denom: :p50, number: 1, value: 50}
    ]
    expect(@coin_holders.dispense_change).to eq(ret)
    
    amount_to_return = 473
    expect(@coin_holders.can_return_exact_change?(amount_to_return)).to be true
    ret = [
      {denom: :p1, number: 1, value: 1}, 
      {denom: :p2, number: 1, value: 2}, 
      {denom: :p20, number: 1, value: 20}, 
      {denom: :p50, number: 1, value: 50 },
      {denom: :p200, number: 2, value: 400 }
    ]
    expect(@coin_holders.dispense_change).to eq(ret)
    
    
    amount_to_return = 473
    @coin_holders.add_coins :p1, 500
    
    expect(@coin_holders.can_return_exact_change?(amount_to_return)).to be true
    ret = [
      {denom: :p1, number: 1, value: 1}, 
      {denom: :p2, number: 1, value: 2}, 
      {denom: :p20, number: 1, value: 20}, 
      {denom: :p50, number: 1, value: 50 },
      {denom: :p200, number: 2, value: 400 }
    ]
    expect(@coin_holders.dispense_change).to eq(ret)
  end
  
  it "lists the coins to returned as change based on an amount, even when a coin holder is empty" do
    
    @coin_holders[:p50].available = 0
    
    amount_to_return = 73
    expect(@coin_holders.can_return_exact_change?(amount_to_return)).to be true
    ret = [
      {denom: :p1, number: 1, value: 1}, 
      {denom: :p2, number: 1, value: 2}, 
      {denom: :p10, number: 1, value: 10}, 
      {denom: :p20, number: 3, value: 60}, 
      
    ]
    expect(@coin_holders.dispense_change).to eq(ret)
  end

  it "indicates a failure if not possible to return the required change" do
    
    @coin_holders[:p10].available = 0
    @coin_holders[:p20].available = 0
    @coin_holders[:p50].available = 0
    @coin_holders[:p100].available = 0
    @coin_holders[:p200].available = 0
    
    amount_to_return = 1*200 + 2*100 + 5*300 
    
    expect(@coin_holders.can_return_exact_change?(amount_to_return)).to be true
    
    amount_to_return = 1*200 + 2*100 + 5*300 + 1
    
    expect(@coin_holders.can_return_exact_change?(amount_to_return)).to be false
    
  end  

  
  it "updates available change based on change being dispensed" do
    amount_to_return = 473
    expect(@coin_holders.can_return_exact_change?(amount_to_return)).to be true
    ret = [
      {denom: :p1, number: 1, value: 1}, 
      {denom: :p2, number: 1, value: 2}, 
      {denom: :p20, number: 1, value: 20}, 
      {denom: :p50, number: 1, value: 50 },
      {denom: :p200, number: 2, value: 400 }
    ]
    expect(@coin_holders.dispense_change).to eq(ret)
    
    expect(@coin_holders[:p1].available).to eq @initial_coin_holders[:p1].available - 1
    expect(@coin_holders[:p2].available).to eq @initial_coin_holders[:p2].available - 1
    expect(@coin_holders[:p20].available).to eq @initial_coin_holders[:p20].available - 1
    expect(@coin_holders[:p50].available).to eq @initial_coin_holders[:p50].available - 1
    expect(@coin_holders[:p200].available).to eq @initial_coin_holders[:p200].available - 2
    
  end
  
  it "updates available change based on coins inserted" do
    @coin_holders.insert_coin :p1
    @coin_holders.accept_inserted_coins
    expect(@coin_holders[:p1].available).to eq @initial_coin_holders[:p1].available + 1
    
    
    
    @coin_holders.insert_coin :p1
    @coin_holders.accept_inserted_coins
    expect(@coin_holders[:p1].available).to eq @initial_coin_holders[:p1].available + 2
    
    22.times { @coin_holders.insert_coin :p10 }
    @coin_holders.accept_inserted_coins
    expect(@coin_holders[:p10].available).to eq @initial_coin_holders[:p10].available + 22
    
    1000.times { @coin_holders.insert_coin :p20 }
    @coin_holders.accept_inserted_coins
    expect(@coin_holders[:p20].available).to eq @initial_coin_holders[:p20].capacity
    expect(@coin_holders.coin_overflow).to eq [{denom: :p20, number: 1000 - @initial_coin_holders[:p20].space }]
    
    2000.times { @coin_holders.insert_coin :p50 }
    @coin_holders.accept_inserted_coins
    expect(@coin_holders[:p50].available).to eq @initial_coin_holders[:p50].capacity
    expect(@coin_holders.coin_overflow).to eq [
      {denom: :p20, number: 1000 - @initial_coin_holders[:p20].space },
      {denom: :p50, number: 2000 - @initial_coin_holders[:p50].space }      
     ]
    
  end
  
  it "doesn't update available change if inserted coins are returned" do
    @coin_holders.insert_coin :p1
    @coin_holders.return_inserted_coins
    expect(@coin_holders[:p1].available).to eq @initial_coin_holders[:p1].available
    
    @coin_holders.insert_coin :p1
    @coin_holders.accept_inserted_coins
    expect(@coin_holders[:p1].available).to eq @initial_coin_holders[:p1].available + 1
  end
  
  it "allows the coin overflow bucket to be emptied, listing the coins in the bucket" do
    expect(@coin_holders.empty_overflow.length).to eq 0
    2000.times { @coin_holders.insert_coin :p10 }
    @coin_holders.accept_inserted_coins
    
    c = @coin_holders.empty_overflow.first
    expect(c[:denom]).to eq(:p10)
    expect(c[:number]).to eq( 2000 - @initial_coin_holders[:p10].space  )
  end

end

