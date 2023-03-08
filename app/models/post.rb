require 'json'
require 'clicksend_client'

class Post < CommunicationRecord
  
  def self.send_post(letter_url, name, return_address_id, address_line_1, address_line_2,
                     address_city, address_state, address_zipcode, priority_flag=false)

    # PostLetter | PostLetter model
    api_instance = ClickSendClient::PostLetterApi.new
    post_letter = ClickSendClient::PostLetter.new(
      "file_url": letter_url,
      "recipients": [
		      {
                        "return_address_id": return_address_id,
	               "schedule": 0,
                       "address_name": name,
                       "address_line_1": address_line_1,
                       "address_line_2": address_line_2,
                       "address_city": address_city,
                       "address_state": address_state,
                       "address_postal_code": address_zipcode,
                       "address_country": "US"
                      }
                    ],
      "priority_post": priority_flag,
      "template_used": 1,
      "duplex": 0,
      "colour": 0
    )
    
    begin
      # Send post letter
      result = api_instance.post_letters_send_post(post_letter)
      logger.info "Sending letter to be posted..."
      logger.info result
      return true
    rescue ClickSendClient::ApiError => e
      puts "Exception calling PostLetterApi->post_letters_send_post: #{e.response_body}"
    end
    return false
  end  

  # Class method
  def self.create_return_address(name, line_1, line_2, city, state, zipcode)
    
    return_addreess_id = false
    api_instance = ClickSendClient::PostReturnAddressApi.new
    
    # Address | Address model
    return_address = ClickSendClient::Address.new(
      "address_postal_code": zipcode,
      "address_country": "US",
      "address_line_1": line_1,
      "address_state": state,
      "address_name": name,
      "address_line_2": line_2,
      "address_city": city
    )

    begin
      # Create post return address
      result = api_instance.post_return_addresses_post(return_address)
      result = JSON.parse(result)
      return_address_id = result['data']['return_address_id']
    rescue ClickSendClient::ApiError => e
      puts "Exception calling PostReturnAddressApi->post_return_addresses_post:"
      puts "#{e.response_body}"
    end
    
    return return_address_id
  end

  def self.get_return_address_id(name, line_1, line_2, city, state, zipcode)

    return_address_id = nil
    max_return_address_limit = 100
    
    api_instance = ClickSendClient::PostReturnAddressApi.new
    
    opts = {
      page: 1,  # Integer | Page number
      limit: 10000 # Integer | Number of records per page
    }
    
    begin
      # Get list of post return addresses
      result = api_instance.post_return_addresses_get(opts)
      return_addresses = JSON.parse(result)
      return_addresses = return_addresses['data']['data']

      # Iterate over all return addresses
      for return_address in return_addresses        
        if return_address['address_name'].eql? name and
          return_address['address_line_1'].eql? line_1 and
          return_address['address_line_2'].eql? line_2 and
          return_address['address_city'].eql? city and
          return_address['address_state'].eql? state and
          return_address['address_postal_code'].eql? zipcode

          return_address_id = return_address['return_address_id']
          break
        end
      end

      # Can't find already created address and count is too high, delete
      if not return_address_id
        if return_addresses.count == max_return_address_limit
          idx = return_addresses.count - 1 # get last index
          
          # Select oldest return address and delete
          oldest_return_address_id = return_addresses[idx]['return_address_id']
          result = api_instance.post_return_addresses_by_return_address_id_delete(
            oldest_return_address_id)
        end

        # Create new
        return_address_id = self.create_return_address(name, line_1, line_2,
                                                       city, state, zipcode)
        
      end      
    rescue ClickSendClient::ApiError => e
      puts "Exception when calling PostReturnAddressApi->post_return_addresses_get: #{e.response_body}"
    end
    
    return return_address_id
    
  end
end
