
# This is the dispenser that controls coin holders of each denomination
# Accepts coins of various denominations
# Coins are valued in pence, and denominations are :p1 (1p), :p2 (2p), ..., :p200 (2 pounds)
# The implementation allows for additional payment types (tokens, coupons, etc)
# to be used in the future, since multiple 'denomination' symbols can have the same value
# Coins that have been inserted will be used to top up the available coins for change
# Any coins that exceed the capacity of a specific coin holder will end up in an overflow bucket
# which the maintainer can empty periodically
# 
# The aim is for this object to be the primary interface through which a vending machine maintainer 
# tops up coins for change
# 
# We can reference a specific coin holder directly by using an object of this class like a hash (change[:p2])

require 'coin_holder'

class CoinHolders

  
  attr_accessor :coin_holders, :coin_overflow
  
  def initialize initial_coins=nil
    create_coin_holders
    
    load_initial_coins initial_coins
    
    # create a bucket of overflow coins
    @coin_overflow = []
  end
  
  # allow direct reference of a coin holder by denom key
  # e.g. change[:p1] 
  def [] k
    @coin_holders.select{|c| c.denom == k}.first
  end
  
  def each *args, &block
    @coin_holders.each *args, &block 
  end
  
  def denominations
    @coin_holders.map(&:denom)
  end
  
  def coin_holder_value
    @coin_holders
  end
  
  def add_coins denom, num
    throw "no such denomination" unless self[denom]
    throw "at least one coin must be added" if num < 1 
   
    self[denom].add_coins num    
  end
  
  def return_inserted_coins
    @coin_holders.collect{|c| {denom: c.denom, number: c.return_inserted_coins} }.reject {|c| c[:number].nil? || c[:number] == 0}
  end
  
  def insert_coin denom    
    self[denom].insert_coin    
  end
  
  def inserted_coins_value
    @coin_holders.map(&:inserted_coins_value).reduce(:+)
  end
  
  def add_coins_to_overflow denom, number
    @coin_overflow << {denom: denom, number: number}
  end
  
  def empty_overflow
    c = @coin_overflow 
    @coin_overflow  = []
    return c
  end
  
  def reset_held_coins
    @coin_holders.each(&:reset_held_coins)
  end
  
  def dispense_change
    
    res = @coin_holders.collect(&:dispense_held_coins).compact
    accept_inserted_coins
    res
  end
  
  def total_value
    @coin_holders.map(&:total_value).reduce(:+)
  end
  
  def can_return_exact_change? amount_to_return
    
    # get the keys to the coins in descending value order
    desc_value_coins = @coin_holders.sort_by(&:value).reverse
    
    # reset the coins held aside in each coin holder, to start this transaction afresh
    reset_held_coins
    
    remaining = amount_to_return

    desc_value_coins.each do |c|
      
      # the optimal number of coins to return (this is int / int = int)      
      optimal_num = remaining / c.value
      # the amount remaining is less than the value of this coin, so move on
      next if optimal_num == 0
      # use as many coins as we have available      
      use_coins = [optimal_num, c.available].min
      # set aside these coins
      c.hold_coins use_coins
      
      remaining -= c.held_coins_value
      
      break if remaining == 0      
    end
    
    return remaining == 0
    
  end

  
  def accept_inserted_coins
    @coin_holders.each do |c|      
      excess = c.accept_inserted_coins
      add_coins_to_overflow(c.denom, excess) if excess > 0
    end
  end
  
private

  def create_coin_holders
    
    @coin_holders = [
      CoinHolder.new(:p1, 1),
      CoinHolder.new(:p2, 2),
      CoinHolder.new(:p5, 5),
      CoinHolder.new(:p10, 10),
      CoinHolder.new(:p20, 20),
      CoinHolder.new(:p50, 50),
      CoinHolder.new(:p100, 100),
      CoinHolder.new(:p200, 200)
    ]
  end

  # load the coin holders with an initial set of coins
  # based on a hash of {denom: available, ...}
  def load_initial_coins coin_hash
    return unless coin_hash    
    coin_hash.each do |k,v|      
      self[k].reset_available v 
    end
    
  end
  
end
