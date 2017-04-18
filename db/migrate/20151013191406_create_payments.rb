class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :amount, null: false
      t.integer :refund_amount, null: false, default: 0
      t.string :description, null: false
      t.integer :method, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.string :reason
      t.string :stripe_charge_id
      t.references :card, index: true, foreign_key: true
      t.references :payable, polymorphic: true, index: true
      t.references :payer, null: false, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end
