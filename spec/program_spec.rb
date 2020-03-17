require 'spec_helper'
require './lib/program'
require 'pry'

RSpec.describe Checkout do
  let(:scarf) { Item.new(name: 'Red scarf', code: '001', price: 9.25) }
  let(:cufflinks) { Item.new(name: 'Silver cufflinks', code: '002', price: 45.00) }
  let(:dress) { Item.new(name: 'Silk dress', code: '002', price: 19.95) }

  # When spending over £60, the customer gets 10% of their purchase.
  # When purchasing 2 or more of the Red Scarf, its price is reduced to £8.50.

  it 'can scan one example' do
    promotional_rules = []
    co = Checkout.new(promotional_rules)

    co.scan(scarf)

    expect(co.total).to eq(9.25)
  end

  it 'discounts 2 scarfs' do
    promotional_rules = [
      Proc.new do |cart|
        number = cart.count(scarf)

        if number > 1
          cart.add_discount(number * 0.75)
        end
      end
    ]

    co = Checkout.new(promotional_rules)

    co.scan(scarf)
    co.scan(scarf)

    expect(co.total).to eq(17.00)
  end

  it 'first example' do
    promotional_rules = [
      Proc.new do |cart|
        total = cart.map { |item| item.price }.reduce(:+)

        if total > 60
          cart.add_discount(total * 0.10)
        end
      end
    ]

    co = Checkout.new(promotional_rules)

    co.scan(scarf)
    co.scan(cufflinks)
    co.scan(dress)

    expect(co.total).to eq(66.78)
  end

  it 'combines rules (discounts calculated from raw total)' do
    promotional_rules = [
      Proc.new do |cart|
        number = cart.count(scarf)

        if number > 1
          cart.add_discount(number * 0.75)
        end
      end,
      Proc.new do |cart|
        total = cart.map { |item| item.price }.reduce(:+)

        if total > 60
          cart.add_discount(total * 0.10)
        end
      end
    ]

    co = Checkout.new(promotional_rules)

    co.scan(scarf)
    co.scan(scarf)
    co.scan(cufflinks)
    co.scan(dress)

    expect(co.total).to eq(73.605)
  end
end
