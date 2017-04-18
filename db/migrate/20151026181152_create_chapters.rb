class CreateChapters < ActiveRecord::Migration
  def change
    create_table :chapters do |t|
      t.integer :handbook, null: false
      t.string :title, null: false
      t.integer :order, null: false

      t.timestamps null: false

      t.index [:order, :handbook], unique: true
    end
  end
end
