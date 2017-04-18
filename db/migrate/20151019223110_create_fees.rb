class CreateFees < ActiveRecord::Migration
  def change
    create_table :fees do |t|
      t.references :booth, index: true, foreign_key: true, null: false
      t.integer :amount, null: false
      t.string :description, null: false

      t.timestamps null: false
    end
  end
end
