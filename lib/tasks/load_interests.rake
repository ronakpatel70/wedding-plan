require 'csv'

# Import vendor show statuses from a CSV
task :load_interests => :environment do
  CSV.foreach("show_statuses.csv") do |row|
    next if row[0] == "id"
    if vendor = Vendor.find_by(id: row[2])
      vendor.update_column("show_statuses", {row[1] => row[3]})
      puts "vendor #{vendor.id}: #{vendor.show_statuses}"
    else
      puts "skipping id: #{row[2]}"
    end
  end
end
