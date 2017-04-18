json.array!(@vendors) do |vendor|
  json.extract! vendor, :id, :name, :cell_phone
  json.text do
    json.id vendor.text_id
    json.message vendor.text_message
    json.status @statuses.invert[vendor.text_status]
    json.created_at vendor.text_created_at.utc
  end
end
