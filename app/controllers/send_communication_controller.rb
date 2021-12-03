require 'stripe'
require 'clicksend_client'
require 'json'

class SendCommunicationController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def send_communication

    Stripe.api_key = ENV['STRIPE_SECRET_KEY_VOCALVOTERS']
    
    method = params['method']
    payment_id = params['payment']['id']
    payment = Stripe::PaymentIntent.retrieve(payment_id)

    # clicksend setup authorization
    ClickSendClient.configure do |config|
      # Configure HTTP basic authorization: BasicAuth
      config.username = ENV['CLICKSEND_USERNAME']
      config.password = ENV['CLICKSEND_PASSWORD']
    end
    
    # If paid, then register communication
    if payment['charges']['data'][0]['paid']
      billing_zipcode = payment['charges']['data'][0]['billing_details']['address']['postal_code']
      recipients = params['recipients'] # should be list of id's

      sender_line_1 = params['sender']['line_1'].presence || ''
      sender_line_2 = params['sender']['line_2'].presence || ''
      sender_city = params['sender']['city'].presence || ''
      sender_state = params['sender']['state'].presence || ''
      sender_zipcode = params['sender']['zipcode'].presence || ''

      # Create sender
      sender = Sender.find_by(email: sender_params[:email])
      if not sender.present?
        sender = Sender.create!(sender_params)
      end
      
      letter_id = letter_params[:id]
      sender_id = sender[:id]
      verified = billing_zipcode.to_i == sender.zipcode.to_i

      # Find recipients
      recipients = Recipient.find(params['recipients'])
      
      recipients.each { |recipient|

        # Fill letter template
        letter_url = '/letters/'+letter_id.to_s+'.pdf?'
        letter_url += 'recipient_name='+recipient.name+'&'
        letter_url += 'recipient_position='+recipient.position+'&'
        letter_url += 'recipient_level='+recipient.level+'&'
        letter_url += 'sender_name='+sender.name+'&'
        letter_url += 'sender_state='+sender.state+'&'
        letter_url += 'sender_district='+recipient.district+'&'
        letter_url += 'sender_verified='+verified.to_s

        address_zipcode = recipient[:address_zipcode]
        to_fax_number = recipient[:number_fax]
        
        # For development, utilize the free options        
        if Rails.env.development?
          letter_url = "https://vocalvoters.com" + letter_url
          address_zipcode = "11111"
          to_fax_number = "61261111111"
        end
        
        case method
        when "priority"
          
          letter_url += "&template=true"
          return_address_id = create_return_address(sender.name, sender_line_1,
                                                    sender_line_2, sender_city,
                                                    sender_state, sender_zipcode)

          success_flag = send_post(
            letter_url, recipient[:name], return_address_id,
            recipient[:address_line_1], recipient[:address_line_2],
            recipient[:address_city], recipient[:address_state],
            address_zipcode, priority_flag=1)

          Post.create!(address_line_1: recipient[:address_line_1],
                       address_line_2: recipient[:address_line_2],
                       address_city: recipient[:address_city],
                       address_state: recipient[:address_state],
                       address_zipcode: address_zipcode,
                       priority: true,
                       sender: sender,
                       recipient: recipient,
                       letter: Letter.find_by(id: letter_id),
                       payment: payment_id,
                       success: success_flag)
          
        when "letter"
          
          letter_url += "&template=true"
          return_address_id = create_return_address(sender.name, sender_line_1,
                                                    sender_line_2, sender_city,
                                                    sender_state, sender_zipcode)
          
          success_flag = send_post(
            letter_url, recipient[:name], return_address_id,
            recipient[:address_line_1], recipient[:address_line_2],
            recipient[:address_city], recipient[:address_state],
            address_zipcode, priority_flag=0)
          
          Post.create!(address_line_1: recipient[:address_line_1],
                       address_line_2: recipient[:address_line_2],
                       address_city: recipient[:address_city],
                       address_state: recipient[:address_state],
                       address_zipcode: address_zipcode,
                       priority: false,
                       sender: sender,
                       recipient: recipient,
                       letter: Letter.find_by(id: letter_id),
                       payment: payment_id,
                       success: success_flag)
          
        when "fax"

          from = "VocalVoters"
          source_method = "rails"
          from_email = sender.email
          
          success_flag = send_fax(letter_url, to_fax_number, from,
                                  source_method, from_email)
            
          Fax.create!(number_fax: to_fax_number,
                      sender: sender,
                      recipient: recipient,
                      letter: Letter.find_by(id: letter_id),
                      payment: payment_id,
                      success: success_flag)
          
        when "email"
          # Do nothing ATM
          # send_email(name, email)
        end
        
      }
      
    end
    
    render status: :ok, json: "Success: No Failures"
  end

  private

    def sender_params
      params.require(:sender).permit(:name, :email, :zipcode,
                                     :county, :district, :state)
    end

    def letter_params
      
      # "id": "1",
      # "category": "bakeries",
      # "sentiment": "Very Supportive",
      # "policy_or_law": "deserts"

      params.require(:letter).permit(:id, :category,
                                     :sentiment, :policy_or_law)
    end

    def send_email(name, email)
      # https://developers.clicksend.com/docs/rest/v3/#send-email
      return false
    end
    

    def send_fax(letter_url, to_fax_number, from, source_method, from_email)
      api_instance = ClickSendClient::FAXApi.new
      
      # FaxMessageCollection | FaxMessageCollection model
      fax_messages = ClickSendClient::FaxMessageCollection.new(
        "file_url": letter_url,
        messages: [
          ClickSendClient::FaxMessage.new(            
            "to": to_fax_number,
            "source": source_method,
            "from": from,
            "country": 'US',
            "from_email": from_email,
            "source": source_method
          )
        ]
      )

      begin
        # Send a fax using supplied supported file-types.
        result = api_instance.fax_send_post(fax_messages)
        return true
      rescue ClickSendClient::ApiError => e
        puts "Exception when calling FAXApi->fax_send_post: #{e.response_body}"
      end
      return false
    end
    
    def create_return_address(name, line_1, line_2, city, state, zipcode)
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
        return result['data']['return_address_id']
      rescue ClickSendClient::ApiError => e
        puts "Exception calling PostReturnAddressApi->post_return_addresses_post: #{e.response_body}"
      end
      return false
    end

    def send_post(letter_url, name, return_address_id, address_line_1, address_line_2,
                  address_city, address_state, address_zipcode, priority_flag=0)

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
        return true
      rescue ClickSendClient::ApiError => e
        puts "Exception calling PostLetterApi->post_letters_send_post: #{e.response_body}"
      end
      return false
    end
    
end
