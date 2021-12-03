json.extract! fax, :id, :number_fax, :sender_id, :recipient_id, :letter_id, :payment_id, :created_at, :updated_at
json.url fax_url(fax, format: :json)
