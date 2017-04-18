require 'http'

class CampaignMonitor
  API = 'https://api.createsend.com/api/v3.1'
  KEY = Rails.application.secrets.campaign_monitor_key

  # Friendly list names to use in all methods
  LISTS = {
    :booths => '5287862d9aba95a8a3495664b188f6a0',
    :customers => '1d2d561bea9178cf98788deaeb80edfe',
    :staff => '1112a86b8637e0f521113b8f25a77ac1',
    :vendors => 'b063b4709abc70564b84810732ed7b8b'
  }

  # Adds a new subscriber with with a name and email to the named list.
  # Custom fields can be a hash of keys and string values to attach to the subscriber.
  def self.add_subscriber(list, name, email, custom_fields = nil)
    url = API + "/subscribers/#{LISTS[list]}.json"
    json = subscriber_json(name, email, custom_fields)
    json.merge!('Resubscribe' => false, 'RestartSubscriptionBasedAutoresponders' => false)

    resp = HTTP.basic_auth(user: KEY, pass: nil).post(url, json: json)
    if resp.status == 201
      Rails.logger.info("CampaignMonitor [#{list.to_s}] 201 Created - #{resp.body}")
    else
      Rails.logger.error("CampaignMonitor [#{list.to_s}] #{resp.status} - #{url} - #{resp.body}")
    end
  end
              
  # Adds multiple subscribers to the named list at once.
  def self.import_subscribers(list, subscribers)
    url = API + "/subscribers/#{LISTS[list]}/import.json"
    json = {
      "Subscribers" => subscribers.map { |sub| subscriber_json(*sub) },
      "Resubscribe" => false,
      "QueueSubscriptionBasedAutoResponders" => false,
      "RestartSubscriptionBasedAutoresponders" => false
    }

    resp = HTTP.basic_auth(user: KEY, pass: nil).post(url, json: json)
    puts resp.body
    if resp.status == 201
      Rails.logger.info("CampaignMonitor [#{list.to_s}] 201 Created - #{resp.body}")
    else
      Rails.logger.error("CampaignMonitor [#{list.to_s}] #{resp.status} - #{url} - #{resp.body}")
    end
  end

  def self.update_subscribers(list, subscriber, new_email)
      url = API + "/subscribers/#{LISTS[list]}.json?email=#{subscriber[0][1]}"
      vendor_data = subscriber.map { |sub| subscriber_json(*sub)}[0]["Name"]

      json = {
          "EmailAddress" => new_email,
          "Name" => vendor_data["Name"],
          "CustomFields" => vendor_data["CustomFields"],
          "Resubscribe" => true,
          "RestartSubscriptionBasedAutoresponders" => true
      }

      resp = HTTP.basic_auth(user: KEY, pass: nil).put(url, json: json)
      puts resp.body
      if resp.status == 200
        Rails.logger.info("CampaignMonitor [#{list.to_s}] 200 Created - #{resp.body}")
      else
        Rails.logger.error("CampaignMonitor [#{list.to_s}] #{resp.status} - #{url} - #{resp.body}")
      end
  end


  private
    def self.subscriber_json(name, email, custom_fields = nil)
      subscriber = { 'EmailAddress' => email, 'Name' => name }

      if custom_fields
        subscriber['CustomFields'] = custom_fields.map do |field|
          if field[1] == nil || field[1] == ''
            { "Key" => field[0], "Value" => '', "Clear" => true }
          else
            { "Key" => field[0], "Value" => field[1] }
          end
        end
      end

      return subscriber
    end
end
