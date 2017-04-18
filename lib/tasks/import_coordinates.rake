def fetch(http, model, path)
  # Get JSON from the API.
  resp = http.get(API + path)
  if resp.status == 401
    puts 'Authentication failed.'
    exit 1
  end

  objects = JSON.parse(resp.body)
  new, updated, failed = 0, 0, 0
  objects.each do |attrs|
    if block_given?
      # Pass the attributes to the provided block; skip this object if it returns nil.
      attrs = yield(attrs.symbolize_keys) or next
    end
  end

  skipped = objects.count - new - updated - failed
  puts "#{model.to_s.underscore.humanize.pluralize}: #{new} new, #{updated} changed, #{failed} failed, #{skipped} skipped"
end

def get_token
  unless token = ENV['WCB_TOKEN']
    print 'API token: '
    token = STDIN.noecho(&:gets).chomp
    puts
  end
  return token
end

task :import_coordinates => :environment do
  ARGV.each { |a| task a.to_sym do ; end }
  show_id = ARGV[1]
  HTTP.auth('Token token=' + get_token).persistent(API) do |http|
    fetch(http, Vendor, "/reports/map.json?show=#{show_id}") do |booth|
      b = Booth.find_by(id: booth[:id])
      coord = booth[:coordinates]
      next unless b && coord && booth[:section_given]
      puts "##{b.id}: #{coord} #{booth[:section_given]}"
      b.coordinate = Coordinate.new(x: coord['x'], y: coord['y'], a: coord['a'], section: booth[:section_given])
      b.save!
    end
  end
end
