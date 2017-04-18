class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.text :name, null: false
      t.text :street, null: false
      t.text :city, null: false
      t.string :state, null: false, default: 'CA', limit: 2
      t.string :zip, null: false, limit: 5

      t.timestamps null: false
    end
  end
end
