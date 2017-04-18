json.array!(@positions) do |position|
  json.extract! position, :id, :name, :short_description, :default_start, :default_end, :active
  json.description Markdown.render(position.description)
end
