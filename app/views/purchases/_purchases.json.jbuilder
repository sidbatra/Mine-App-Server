json.array! purchases do |json,purchase|
  json.partial! purchase, defined?(extra) ? extra : {}
end
