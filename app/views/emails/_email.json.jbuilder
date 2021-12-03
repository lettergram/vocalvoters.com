json.extract! email, :id, :email_address, :sender_id, :recipient_id, :letter_id, :payment_id, :created_at, :updated_at
json.url email_url(email, format: :json)
