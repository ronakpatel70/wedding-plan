class AddIndustriesToBooth < ActiveRecord::Migration
  def change
    add_column :booths, :industries, :string, array: true, null: false, default: []
  end
end
