class CreateShows < ActiveRecord::Migration
  def change
    create_table :shows do |t|
      t.references :location, index: true, foreign_key: true, null: false
      t.datetime :start, null: false
      t.datetime :end, null: false

      t.timestamps null: false
    end

    create_join_table :shows, :users
  end
end
