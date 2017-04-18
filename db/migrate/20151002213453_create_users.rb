class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email, null: false, limit: 254
      t.text :password_digest
      t.text :first_name, null: false
      t.text :last_name, null: false
      t.string :phone
      t.references :address, index: false, foreign_key: true
      t.integer :gender, null: false, default: 0
      t.boolean :receive_email, null: false, default: true
      t.boolean :receive_sms, null: false, default: false
      t.text :stripe_customer_id
      t.text :stripe_recipient_id
      t.references :default_card

      t.integer :failed_attempts, null: false, default: 0
      t.datetime :locked_at
      t.datetime :password_updated_at

      t.timestamps null: false

      t.index :email, unique: true
      t.index :stripe_customer_id, unique: true
      t.index :stripe_recipient_id, unique: true
    end

    add_foreign_key :users, :cards, column: :default_card_id
  end
end
