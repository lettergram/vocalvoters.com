json.sender do
  json.address @sender_address
  json.zipcode @sender_zipcode
  json.county @sender_county
  json.district @sender_district
  json.state @sender_state
  json.address_accuracy @address_accuracy
end
json.recipients do 
  json.array! @recipients, partial: "recipients/recipient", as: :recipient
end
