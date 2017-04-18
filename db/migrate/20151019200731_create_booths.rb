class CreateBooths < ActiveRecord::Migration
  def change
    create_table :booths do |t|
      t.references :show, index: true, foreign_key: true, null: false
      t.references :vendor, index: true, foreign_key: true, null: false
      t.integer :status, null: false, default: 0

      t.string :section_requested
      t.string :size
      t.string :amenities, array: true
      t.text :requests

      t.references :coordinate, foreign_key: true
      t.references :sign, foreign_key: true

      t.integer :total, null: false, default: 0
      t.integer :balance, null: false, default: 0
      t.integer :payment_method, null: false, default: 0
      t.integer :payment_schedule, null: false, default: 0
      t.references :card, index: true, foreign_key: true

      t.boolean :visible, null: false, default: true
      t.boolean :leads_access, null: false, default: true
      t.boolean :flagged, null: false, default: false
      t.boolean :received_marketing, null: false, default: false
      t.integer :free_pass_limit, null: false, default: 25

      t.datetime :checked_in_at
      t.timestamps null: false

      t.index [:show_id, :sign_id], unique: true
    end
  end
end
