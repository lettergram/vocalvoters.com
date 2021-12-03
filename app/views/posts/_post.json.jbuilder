json.extract! post, :id, :address_line_1, :address_line_2, :address_city, :address_state, :address_zipcode, :sender_id, :recipient_id, :letter_id, :payment_id, :created_at, :updated_at
json.url post_url(post, format: :json)
