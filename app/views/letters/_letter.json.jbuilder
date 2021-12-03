json.extract! letter, :id, :category, :policy_or_law, :sentiment, :body, :user_id, :created_at, :updated_at
json.url letter_url(letter, format: :json)
