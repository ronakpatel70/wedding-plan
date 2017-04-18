class MakeAddressNameNullable < ActiveRecord::Migration[5.0]
  def change
    change_column :addresses, :name, :text, null: true, default: nil
  end
end
