include ActiveSupport::NumberHelper

namespace :cm do

  task :sync => :environment do
    users = User.joins(:roles).where("users.receive_email = true AND users.updated_at > ?", Time.now - 48.hours).distinct
    CampaignMonitor.import_subscribers(:staff, subscriber_array(users))

    # For import new vendor
    vendors = Vendor.joins("LEFT OUTER JOIN addresses a ON a.id = vendors.storefront_address_id").where("vendors.updated_at > :now OR a.updated_at > :now", now: Time.now - 48.hours).where("vendors.updated_at = vendors.created_at")
    CampaignMonitor.import_subscribers(:vendors, subscriber_array(vendors))

    customers = User.joins(:events).where("users.receive_email = true AND users.updated_at > :now OR events.updated_at > :now", now: Time.now - 48.hours)
    CampaignMonitor.import_subscribers(:customers, subscriber_array(customers))

    booths = Booth.approved.where(show: Show.next).where("updated_at > ?", Time.now - 48.hours)
    CampaignMonitor.import_subscribers(:booths, subscriber_array(booths))
  end
  
  namespace :sync do
    task :all => :environment do
      users = User.joins(:roles).where(receive_email: true).all.distinct
      CampaignMonitor.import_subscribers(:staff, subscriber_array(users))

      batches = (Vendor.all.count / 1000.0).ceil
      batches.times do |i|
        vendors = Vendor.all.limit(1000).offset(i * 1000)
        CampaignMonitor.import_subscribers(:vendors, subscriber_array(vendors))
      end

      batches = (User.joins(:events).where("users.receive_email = true").distinct.count / 1000.0).ceil
      batches.times do |i|
        customers = User.joins(:events).where("users.receive_email = true").distinct.limit(1000).offset(i * 1000)
        CampaignMonitor.import_subscribers(:customers, subscriber_array(customers))
      end
     
      booths = Booth.approved.where(show: Show.next)
      CampaignMonitor.import_subscribers(:booths, subscriber_array(booths))
    end
  end

  def subscriber_array(objects)
    future_shows = Show.select('id, start').future.order('start DESC').to_a
    subscribers = []

    objects.each do |object|
      custom = []
      if object.is_a?(Booth)
        custom << ['ShowDate', object.show.date.to_s(:db)]
        custom << ['Industry', object.vendor.industry]
        custom << ['RewardsStatus', object.vendor.rewards_status]
        custom << ['Size', object.size]
        custom << ['Section', object.coordinate&.section]
        custom << ['LoadInDoor', object.door]
        custom << ['PaymentMethod', object.payment_method]
        custom << ['PaymentSchedule', object.payment_schedule]
        custom << ['Balance', number_to_currency(object.balance / 100.0)]
        custom << ['Total', number_to_currency(object.total / 100.0)]
        custom << ['URL', "https://weddingexpo.co/account/booths/#{object.id}"]
        custom << ['StorefrontAddress', object.vendor.storefront_address&.to_s]
        custom << ['ReceivedMarketing', object.received_marketing.to_s]
        custom += object.add_ons.pluck(:type).map { |am| ['Amenities', am] }
        prizes = Prize.highlighted.approved.where(vendor: object.vendor, show: object.show)
        if prizes.present?
          custom << ['HighlightedGiveaway', prizes[0].name]
        end
        subscribers << [object.vendor.to_s, object.vendor.email, custom]
        next
      elsif object.is_a?(Vendor)
        custom << ['ContactName', object.primary&.first_name]
        custom << ['Industry', object.industry]
        custom << ['RewardsStatus', object.rewards_status]
        custom << ['LastShow', last_show_date(object)]
        custom << ['NextShow', nsd = next_show_date(object.id)]
        custom << ['StorefrontAddress', object.storefront_address&.to_s]
        unless nsd
          custom << ['NextShowInterestedIn', next_show_with_status(object, 'interested', future_shows)]
          custom << ['NextShowLeadFor', next_show_without_status(object, future_shows)]
        end
      elsif object.roles.count > 0
        custom << ['Phone', object.phone]
        custom += object.roles.map { |role| ['role', role.type] }
      else
        custom << ['WeddingDate', object.events.first&.date]
        custom << ['RewardsJoinDate', object.events.first&.joined_rewards_at&.to_date&.to_s(:db)]
        custom << ['City', object.address&.city]
        custom << ['LastShow', last_show_date(object)]
      end
      subscribers << [object.to_s, object.email, custom]
    end

    return subscribers
  end

  def last_show_date(obj)
    if obj.is_a? Vendor
      booth = Booth.joins(:show).includes(:show).approved.where("vendor_id = ? AND shows.start < ?", obj.id, Date.today).order('shows.start DESC').limit(1).first
      booth&.show&.date&.to_s(:db)
    else
      obj.shows.where("start < ?", Date.today).order('shows.start DESC').limit(1).first&.date&.to_s(:db)
    end
  end

  def next_show_date(vid)
    booth = Booth.joins(:show).includes(:show).approved.where("vendor_id = ? AND shows.start >= ?", vid, Date.today).order('shows.start ASC').limit(1).first
    booth&.show&.date&.to_s(:db)
  end

  def next_show_with_status(vendor, status, future_shows)
    show_ids = vendor.show_statuses.select { |sh, st| st == status }.keys
    shows = future_shows.select { |sh| show_ids.include?(sh.id.to_s) }
    return shows[0]&.date&.to_s(:db)
  end

  def next_show_without_status(vendor, future_shows)
    shows = future_shows.reject { |sh| vendor.show_statuses.has_key?(sh.id.to_s) }
    return shows[0]&.date&.to_s(:db)
  end

end
