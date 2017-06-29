# Specifications for the definition of a product line and adding items to be sold

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'products'
require 'coin_holders'

describe Products do
  before(:each) do
    @products = Products.new
    @product = build(:product)
  end

  it "knows the cost of a product" do
    expect(@product.price).to eq 74
  end
  
  it "accepts reload of products and tracks how many products are remaining" do
    
    p = @products.create_product @product
    @products.add_items(155, 21)
    expect(@products[155].available).to eq 21
  end

  
end

