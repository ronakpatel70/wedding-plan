json.array!(@signs) do |sign|
  json.extract! sign, :id, :front, :back, :missing, :informational
  json.url sign_url(sign, format: :json)
end
