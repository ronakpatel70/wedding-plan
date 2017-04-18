class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.string :title, null: false
      t.text :content
      t.integer :order, null: false
      t.references :chapter, index: true, foreign_key: true, null: false

      t.timestamps null: false

      t.index [:order, :chapter_id], unique: true
    end
  end
end
