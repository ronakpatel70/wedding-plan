class MakePositionDefaultTimesRequired < ActiveRecord::Migration[5.0]
  def change
    change_column :positions, :default_start, :string, null: false, default: "10:30am"
    change_column :positions, :default_end, :string, null: false, default: "5:00pm"
  end
end
