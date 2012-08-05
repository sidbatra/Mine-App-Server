json.extract! user, :id,:handle,:first_name,:last_name,:gender,:square_image_url
json.extract! user, :byline if defined? byline
