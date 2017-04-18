class CreateTestimonials < ActiveRecord::Migration
  def change
    create_table :testimonials do |t|
      t.references :vendor, index: true, foreign_key: true, null: false
      t.text :quote, null: false
      t.string :author

      t.timestamps null: false
    end
  end
end
