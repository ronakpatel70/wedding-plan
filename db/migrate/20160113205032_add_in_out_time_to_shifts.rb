class AddInOutTimeToShifts < ActiveRecord::Migration
  def change
    add_column :shifts, :in_time, :datetime
    add_column :shifts, :out_time, :datetime
  end
end
