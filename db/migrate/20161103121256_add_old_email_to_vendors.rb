class AddOldEmailToVendors < ActiveRecord::Migration[5.0]
  def change
    add_column :vendors, :old_email, :string
  end
end
