json.array!(@transfers) do |transfer|
  json.extract! transfer, :id
  json.url transfer_url(transfer, format: :json)
end
