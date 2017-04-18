class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.references :owner, polymorphic: true, index: true
      t.string :stripe_card_id, null: false
      t.string :brand, null: false
      t.string :funding
      t.date :expiry, null: false
      t.string :last4, limit: 4, null: false
      t.string :name, null: false
      t.integer :status, null: false, default: 0

      t.timestamps null: false
    end
  end
end
