class AddGrabCardStatusToVendors < ActiveRecord::Migration
  def change
    add_column :vendors, :grab_card_status, :integer, null: false, default: 0
    add_column :vendors, :has_slides, :boolean, null: false, default: false
  end
end
