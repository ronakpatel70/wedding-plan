class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.text :handle, null: false
      t.text :name, null: false
      t.references :address, index: true, foreign_key: true, null: false

      t.timestamps null: false

      t.index :handle, unique: true
    end
  end
end
