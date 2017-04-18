namespace :booths do
  namespace :add_ons do
    task :restore => :environment do
      file = File.read('add_ons.json')
      add_ons = JSON.parse(file)
      add_ons.each do |add_on|
        AddOn.create!(add_on)
      end
      puts "Restored #{add_ons.length} add-ons."
    end
  end

  namespace :tables do
    task :set_size => :environment do
      AddOn.where(type: 'tables').each do |add_on|
        size = add_on.booth.size
        next unless size
        config = Config.booths[size]
        add_on.update_column('value', config[:table])
        puts "#{size}: #{add_on.value}"
      end
    end
  end
end
