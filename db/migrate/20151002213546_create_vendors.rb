class CreateVendors < ActiveRecord::Migration
  def change
    create_table :vendors do |t|
      t.text :name, null: false
      t.text :former_name
      t.string :email, null: false, limit: 254
      t.string :phone, null: false
      t.text :contact, null: false
      t.references :billing_address
      t.references :storefront_address
      t.integer :industry, null: false, default: 22
      t.text :website
      t.text :facebook
      t.text :stripe_customer_id
      t.references :default_card
      t.integer :rewards_status, null: false, default: 0
      t.text :rewards_profile
      t.attachment :profile_image

      t.timestamps null: false

      t.index :name, unique: true
      t.index :former_name
      t.index :stripe_customer_id, unique: true
    end

    add_foreign_key :vendors, :addresses, column: :billing_address_id
    add_foreign_key :vendors, :addresses, column: :storefront_address_id
    add_foreign_key :vendors, :cards, column: :default_card_id
    create_join_table :users, :vendors
  end
end
