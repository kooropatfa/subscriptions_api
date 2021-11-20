class CreateSubscriptions < ActiveRecord::Migration[6.1]
  def change
    create_table :subscriptions do |t|
      t.string :customer_name, null: false
      t.string :customer_address, null: false
      t.string :customer_zip_code, null: false
      t.datetime :renewal_date, null: false
      t.string :payment_auth_token, null: false
      t.references :product, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
