class ConvertBookingsToPoints < ActiveRecord::Migration[5.0]
  def change
    rename_table :bookings, :points
    add_column :points, :quantity, :integer, null: false, default: 1
    add_column :vendors, :allow_multi_points, :boolean, null: false, default: false
  end
end
