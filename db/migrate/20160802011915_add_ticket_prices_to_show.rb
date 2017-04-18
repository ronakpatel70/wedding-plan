class AddTicketPricesToShow < ActiveRecord::Migration[5.0]
  def change
    add_column :shows, :early_bird_price, :integer, null: false, default: 1200
    add_column :shows, :online_price, :integer, null: false, default: 1200
    add_column :shows, :door_price, :integer, null: false, default: 1500
    add_column :shows, :wine_tasting_price, :integer, null: false, default: 500
  end
end
