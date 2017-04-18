class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.date :date
      t.integer :rewards_points, null: false, default: 1
      t.datetime :joined_rewards_at

      t.timestamps null: false

      t.index :date
    end

    create_join_table :events, :users
  end
end
