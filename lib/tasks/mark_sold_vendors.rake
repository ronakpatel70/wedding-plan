task :mark_sold_vendors => :environment do
  booths = Show.fresh.collect(&:booths).flatten
  booths.each do |booth|
    statuses = booth.vendor.show_statuses.merge(booth.show_id.to_s => "sold")
    booth.vendor.update_column("show_statuses", statuses)
  end
end
