json.array!(@shows) do |show|
  json.extract! show, :id, :start, :end, :date
  json.pretty_date show.date.to_s(:semiformal)
  json.url show_url(show, format: :json)
end
