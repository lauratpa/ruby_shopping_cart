class Item
  attr_reader :price

  def initialize(name:, code:, price:)
    @name = name
    @code = code
    @price = price
  end
end

class Checkout
  def initialize(rules)
    @rules = rules
    @cart = Cart.new
  end

  def scan(item)
    @cart.add(item)
  end

  def total
    cart.map { |item| item.price }.reduce(:+) - discount
  end

  private

  attr_reader :rules
  attr_reader :cart

  def discount
    rules.map { |rule| rule.call(cart) }.reduce(:+) || 0
  end
end

class Cart
  include Enumerable

  def initialize
    @items = []
    @discount = 0
  end

  def add(item)
    @items.push(item)
  end

  def each
    @items.each do |item|
      yield item
    end
  end

  def add_discount(amount)
    @discount =+ amount
  end
end
