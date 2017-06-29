FactoryGirl.define do
  
  factory :coin_holders do
    # total amount
    # 1*200 + 2*100 + 5*300 + 10*80 + 20*100 + 50*40 + 100*30 + 200*20 
    
    initialize_with { new({
        p1: 200,
        p2: 100,      
        p5: 300,
        p10: 80,
        p20: 100,
        p50: 40,
        p100: 30,
        p200: 20      
    }) }
    
  end
  
end