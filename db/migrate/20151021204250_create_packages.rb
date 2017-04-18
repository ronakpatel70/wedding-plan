class CreatePackages < ActiveRecord::Migration
  def change
    create_table :packages do |t|
      t.references :show, index: true, foreign_key: true, null: false
      t.integer :ribbon
      t.integer :type, null: false, default: 0
      t.string :name
      t.text :rules
      t.references :winner, index: true

      t.timestamps null: false
      t.index [:show_id, :ribbon], unique: true
    end

    add_foreign_key :packages, :users, column: :winner_id
    create_join_table :packages, :prizes
  end
end
