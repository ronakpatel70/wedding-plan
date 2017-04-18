class ChangeGenderToEventRole < ActiveRecord::Migration
  def change
    rename_column :users, :gender, :event_role
  end
end
