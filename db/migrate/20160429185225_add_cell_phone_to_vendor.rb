class AddCellPhoneToVendor < ActiveRecord::Migration
  def change
    add_column :vendors, :cell_phone, :string
  end
end
