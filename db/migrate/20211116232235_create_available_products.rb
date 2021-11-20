class CreateAvailableProducts < ActiveRecord::Migration[6.1]
  def up
    Product.create(name: 'Bronze Box', price: 1999, billing_interval: 1)
    Product.create(name: 'Silver Box', price: 4900, billing_interval: 1)
    Product.create(name: 'Gold Box', price: 9900, billing_interval: 1)
  end

  def down
    Product.destroy_all
  end
end
