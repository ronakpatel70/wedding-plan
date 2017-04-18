class CreateTransfers < ActiveRecord::Migration
  def change
    create_table :transfers do |t|
      t.integer :amount, null: false
      t.string :description, null: false
      t.integer :status, null: false, default: 0
      t.string :failure_message
      t.references :user, null: false, index: true, foreign_key: true
      t.string :stripe_transfer_id, null: false
      t.string :stripe_recipient_id, null: false

      t.timestamps null: false
    end
  end
end
