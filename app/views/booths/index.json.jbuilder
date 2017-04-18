json.array!(@booths.approved) do |booth|
  json.extract! booth, :id, :status, :size, :requests, :checked_in_at
  json.add_ons booth.add_ons do |add_on|
	 json.extract! add_on, :type, :value, :quantity, :price
  end
  json.coordinate do
  	json.extract! booth.coordinate, :x, :y, :a, :section if booth.coordinate
  end
  json.vendor do
	 json.extract! booth.vendor, :id, :name, :industry, :rewards_status, :cell_phone
  end
  json.url booth_url(booth, format: :json)
end
