class CreatePositions < ActiveRecord::Migration
  def change
    create_table :positions do |t|
      t.string :name, null: false
      t.text :description
      t.string :short_description, null: false
      t.integer :quantity, null: false, default: 1
      t.boolean :active, null: false, default: true
      t.string :default_start
      t.string :default_end

      t.timestamps null: false
    end
  end
end
