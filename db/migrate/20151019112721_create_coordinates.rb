class CreateCoordinates < ActiveRecord::Migration
  def change
    create_table :coordinates do |t|
      t.decimal :x, null: false
      t.decimal :y, null: false
      t.decimal :a, null: false, default: 0
      t.string :section, null: false

      t.timestamps null: false
    end
  end
end
