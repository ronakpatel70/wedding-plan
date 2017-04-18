class CreatePrizes < ActiveRecord::Migration
  def change
    create_table :prizes do |t|
      t.references :show, index: true, foreign_key: true, null: false
      t.references :vendor, index: true, foreign_key: true, null: false
      t.string :name, null: false
      t.integer :quantity, null: false, default: 1
      t.integer :value, null: false, default: 1000
      t.text :rules
      t.integer :type, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.references :coordinate, foreign_key: true

      t.timestamps null: false
    end
  end
end
