class CreateJobApplications < ActiveRecord::Migration
  def change
    create_table :job_applications do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.references :show, index: true, foreign_key: true, null: false
      t.integer :status, null: false, default: 0
      t.text :requests
      t.string :requested_start
      t.string :requested_end

      t.timestamps null: false

      t.index [:show_id, :user_id], unique: true
    end
  end
end
