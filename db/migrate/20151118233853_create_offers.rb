class CreateOffers < ActiveRecord::Migration
  def change
    create_table :offers do |t|
      t.references :vendor, index: true, foreign_key: true, null: false
      t.integer :tier, null: false, default: 1
      t.integer :value, null: false, default: 1
      t.integer :type, null: false, default: 0
      t.string :name, null: false
      t.text :rules
      t.boolean :combo, null: false, default: false

      t.timestamps null: false

      t.index [:tier, :vendor_id], unique: true
    end
  end
end
