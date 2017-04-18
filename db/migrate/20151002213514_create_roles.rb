class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :type, null: false, default: nil

      t.timestamps null: false

      t.index [:type, :user_id], unique: true
    end
  end
end
