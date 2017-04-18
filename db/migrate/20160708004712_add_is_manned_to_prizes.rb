class AddIsMannedToPrizes < ActiveRecord::Migration[5.0]
  def change
    add_column :prizes, :is_manned, :boolean, null: false, default: false
  end
end
