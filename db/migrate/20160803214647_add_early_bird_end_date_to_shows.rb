class AddEarlyBirdEndDateToShows < ActiveRecord::Migration[5.0]
  def change
    add_column :shows, :early_bird_end_date, :date
  end
end
