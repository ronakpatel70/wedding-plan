class AddIndexToVendorShowStatuses < ActiveRecord::Migration[5.0]
  def change
    add_index :vendors, :show_statuses, using: :gist
  end
end
