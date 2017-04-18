class AddPrizeRibbonsToShow < ActiveRecord::Migration[5.0]
  def change
    add_column :shows, :prize_ribbons, :integer, null: false, default: 500
    change_column :shows, :prize_ribbons, :integer, null: false, default: 600
  end
end
