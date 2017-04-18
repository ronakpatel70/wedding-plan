class AddShowStatusesToVendors < ActiveRecord::Migration
  def change
    enable_extension "hstore"
    add_column :vendors, :show_statuses, :hstore, null: false, default: {}
  end
end
