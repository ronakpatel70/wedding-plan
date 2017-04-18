class ChangeUserEmailToCaseInsensitive < ActiveRecord::Migration
  def change
    enable_extension "citext"
    change_column :users, :email, :citext, null: false
    change_column :vendors, :email, :citext, null: false
  end
end
