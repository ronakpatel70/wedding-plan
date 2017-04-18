namespace :prizes do
  # Task prizes:generate maps approved prizes for the next show to packages.
  task :generate => :environment do
    show = Show.next
    grand_prizes = show.packages.grand
    slots = show.prize_ribbons - grand_prizes.length
    die("You must provide a positive number of prizes to generate") unless slots > 0

    prizes = show.prizes.approved.joins(:vendor).where(type: [:discount, :standalone])
    total = prizes.sum(:quantity)

    # [[cake, 50], [dj, 75], [catering, 100], ...]
    industries = prizes.group("industry").order("SUM(quantity)").sum("quantity").to_a

    # {cake: [prize1, prize2, ...], dj: [prize1, prize2, ...], ...}
    prizes = prizes.select("prizes.id, quantity, industry").group_by(&:industry)

    # Generate an array of ribbon numbers and shuffle it.
    ribbon_numbers = (1..show.prize_ribbons).to_a.shuffle

    packages = slots.times do |i|
      # Calculate the number of prizes that should go in this package.
      psize = (total.to_f / (slots - i).to_f).ceil
      total -= psize

      # Pick one prize from each of the `psize` industries with the most prizes.
      picks = industries[industries.length-psize...industries.length]
      pids = picks.map do |x|
        prize = prizes[x[0]].pop
        prize.quantity -= 1
        prizes[x[0]].push(prize) if prize.quantity > 0
        prize.id
      end

      # Decrement the quantity of each chosen industry and re-sort the array.
      picks.each { |x| x[1] -= 1 }
      industries.sort! { |a, b| a[1] <=> b[1] }

      # Create a package with the selected prizes and a random ribbon number.
      rib = ribbon_numbers.pop
      Package.create!(type: :standard, show: show, ribbon: rib, name: "Prize ##{rib}", prize_ids: pids)
    end

    # Assign the remaining ribbon numbers to the grand prizes.
    grand_prizes.each { |g| g.update_column('ribbon', ribbon_numbers.pop) }

    puts "Generated #{slots} prizes for the #{show.date} show."
  end

  # Task prizes:reset deletes all standard packages for the next show and clears
  # any assigned ribbon numbers. Pacakges with winners are ignored.
  task :reset => :environment do
    show = Show.next
    packages = show.packages.standard.where(winner_id: nil)
    len = packages.length
    packages.delete_all

    show.packages.where.not(ribbon: nil).update_all(ribbon: nil)

    puts "Deleted #{len} packages for the #{show.date} show."
  end
end
