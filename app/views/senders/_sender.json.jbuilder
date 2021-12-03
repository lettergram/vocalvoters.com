json.extract! sender, :id, :name, :zipcode, :county, :district, :state, :user_id, :created_at, :updated_at
json.url sender_url(sender, format: :json)
