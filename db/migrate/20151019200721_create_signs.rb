class CreateSigns < ActiveRecord::Migration
  def change
    create_table :signs do |t|
      t.string :front, null: false
      t.string :back
      t.boolean :missing, null: false, default: false
      t.boolean :informational, null: false, default: false

      t.timestamps null: false
    end

    create_join_table :signs, :vendors
  end
end
