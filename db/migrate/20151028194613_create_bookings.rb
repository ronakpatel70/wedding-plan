class CreateBookings < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      t.references :event, index: true, foreign_key: true
      t.references :vendor, null: false, index: true, foreign_key: true
      t.integer :status, null: false, default: 0
      t.string :reason
      t.date :date, null: false

      t.timestamps null: false

      t.index [:event_id, :vendor_id], unique: true
    end
  end
end
