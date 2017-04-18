API = 'https://admin.winecountrybride.com'

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

task :import_address => :environment do
  HTTP.auth('Token token=' + get_token).persistent(API) do |http|
    fetch(http, Vendor, '/users/all.json') do |vendor|
      v = Vendor.find_by(id: vendor[:id])
      next if !v || vendor[:address].blank?
      v.billing_address = Address.new(name: v.name, street: vendor[:address],
        city: vendor[:city], state: vendor[:state] || 'CA', zip: vendor[:zip])
      puts v.name + ' | ' + v.billing_address.street
    end
  end
end
