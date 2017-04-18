json.extract! @package, :id, :name, :ribbon
json.winner @package.winner.to_s
json.prizes(@package.prizes) do |prize|
  json.extract! prize, :id, :name, :value
  json.vendor prize.vendor.name
end
