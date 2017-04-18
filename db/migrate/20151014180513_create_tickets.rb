class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.references :show, index: true, foreign_key: true, null: false
      t.references :user, index: true, foreign_key: true, null: false
      t.integer :quantity, null: false, default: 1, limit: 1
      t.boolean :free, null: false, default: false
      t.references :vendor, index: true, foreign_key: true
      t.string :url, limit: 24
      t.boolean :paid, null: false, default: true

      t.timestamps null: false
    end

    add_index :tickets, :url, unique: true
    add_index :tickets, [:show_id, :user_id]
    add_index :tickets, [:show_id, :vendor_id]
  end
end
