class MakeCoordinateSectionNullable < ActiveRecord::Migration[5.0]
  def change
    change_column :coordinates, :section, :string, null: true, default: nil
  end
end
