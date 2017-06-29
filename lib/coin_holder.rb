# A coin holder for a single denomination of coin
# The aim is that a vending machine maintainer should not need to access this directly

class CoinHolder
  # denom - the denomination of a coin, as a symbol
  # value - value of the coin in pence
  # capacity - how many coins this holder can hold
  # available - how many coins of this denomination are held
  attr_reader :denom, :value, :capacity, :inserted_coins, :held_coins
  attr_accessor :available
  
  def initialize denom, value, available=0, capacity=1000
    @denom = denom
    @value = value
    @available = available
    @capacity = capacity
    @held_coins = 0
    @inserted_coins = 0
  end
 
  def space
    @capacity - @available
  end
  
  def add_coins number
    throw "added coins exceeds capacity" if @available + number > @capacity
    @available += number 
  end
  
  def remove_coins number
    throw "removed coins exceeds available" if @available - number < 0
    @available -= number 
  end
  
  def reset_available num
    @available = num
  end
  
  def total_value
    @available * @value
  end
  
  # put aside num coins for this 'transaction'
  def hold_coins num
    @held_coins = num
  end
  
  def held_coins_value
    @held_coins * @value
  end
  
  def dispense_held_coins
    return nil if @held_coins == 0
    remove_coins @held_coins
    {denom: denom, number: @held_coins, value: @held_coins * value}
  end
  
  def reset_held_coins
    @held_coins = 0
  end
  
  def insert_coin
    @inserted_coins += 1
  end
  
  def inserted_coins_value
    @inserted_coins * @value
  end
  
  def return_inserted_coins
    
    i = @inserted_coins
    return nil if i == 0
    @inserted_coins = 0    
    return i
  end
  
  def accept_inserted_coins
    
    # we can store only what we have space for
    use_coins = [space, @inserted_coins].min
    excess = @inserted_coins - use_coins
    add_coins(use_coins)
    @inserted_coins = 0
    return excess
    
  end
  
end
