json.extract! recipient, :id, :name, :position, :level, :district, :state, :number_fax, :number_phone, :email_address, :address_line_1, :address_line_2, :address_city, :address_state, :address_zipcode, :created_at, :updated_at
json.url recipient_url(recipient, format: :json)
