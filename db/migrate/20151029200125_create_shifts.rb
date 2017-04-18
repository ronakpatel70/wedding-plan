class CreateShifts < ActiveRecord::Migration
  def change
    create_table :shifts do |t|
      t.references :user, null: false, index: true, foreign_key: true
      t.references :position, null: false, index: true, foreign_key: true
      t.references :show, null: false, index: true, foreign_key: true
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.integer :status, null: false, default: 0
      t.text :notes

      t.timestamps null: false
    end
  end
end
