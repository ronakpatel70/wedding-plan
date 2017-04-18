namespace :renew do
  # Task renew:booths idempotently copies all Rewards booths from the previous
  # show to the next. It should be run 30 days after every show.
  task :booths => :environment do
    prev_show, next_show = Show.previous, Show.next
    booths_to_renew = prev_show.booths.joins(:vendor).where("vendors.rewards_status = 3")
    booths_to_renew.each do |booth|
      next if next_show.booths.exists?(vendor: booth.vendor)
      # TODO: also duplicate add-ons once those are launched.
      new_booth = next_show.booths.new(vendor: booth.vendor, size: booth.size, requests: booth.requests,
        payment_method: booth.payment_method, payment_schedule: booth.payment_schedule, card: booth.card,
        visible: booth.visible, leads_access: booth.leads_access, industries: booth.industries,
        amenities: booth.amenities, sign: booth.sign)
      new_booth.save!
      new_booth.fees.create!(amount: -10000, description: "Rewards discount")
      puts "Renewed #{new_booth.size} for #{new_booth.vendor}"
    end
  end
end
