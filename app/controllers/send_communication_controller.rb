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
      config.username = ENV["CLICKSEND_USERNAME"]
      config.password = ENV["CLICKSEND_PASSWORD"]
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
      sender_signature = params['sender']['signature'].presence || ''

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
        
        if sender_signature.present?
          sender_signature.sub!("data:image/png;", "") # modify in place
          # If first and last char is quote (typical), replace
          if sender_signature[0] == '"' and sender_signature[-1] == '"'
            sender_signature = sender_signature[1...-1] # Remove quote
          end
          letter_url += 'signature='+sender_signature+'&'
        end        
        letter_url += 'sender_verified='+verified.to_s

        address_zipcode = recipient[:address_zipcode]
        to_fax_number = recipient[:number_fax]
        
        # For development, utilize the free options        
        if Rails.env.development?
          letter_url = "https://vocalvoters.com" + letter_url
          address_zipcode = "11111"
          to_fax_number = "61261111111"
        elsif ENV.has_key?('ROOT_VOCALVOTERS_URL')
          letter_url = ENV['ROOT_VOCALVOTERS_URL'] + letter_url
        end

        letter = Letter.find_by(id: letter_id)
        
        approval_status = "pending"
        success_flag = nil
        if params.has_key?(:approval_status)
          approval_status = approval_status
        end
        
        case method
        when "priority", "letter"

          # Should only be set to approval once
          if approval_status == "approved"            
            letter_url += "&template=true"
            return_address_id = Post.get_return_address_id(
              sender.name, sender_line_1, sender_line_2,
              sender_city, sender_state, sender_zipcode)
            
            priority_flag = (method == "priority")
            
            success_flag = Post.send_post(            
              letter_url, recipient[:name], return_address_id,
              recipient[:address_line_1], recipient[:address_line_2],
              recipient[:address_city], recipient[:address_state],
              address_zipcode, priority_flag=priority_flag
            )
          end
          
          Post.create!(address_line_1: recipient[:address_line_1],
                       address_line_2: recipient[:address_line_2],
                       address_city: recipient[:address_city],
                       address_state: recipient[:address_state],
                       address_zipcode: address_zipcode,
                       return_address_id: return_address_id,
                       priority: priority_flag,
                       approval_status: approval_status,
                       letter_url: letter_url,
                       sender: sender,
                       recipient: recipient,
                       letter: letter,
                       payment: payment_id,
                       success: success_flag)
          
        when "fax"

          source_method = "VocalVoters"
          from = "from"
          from_email = sender.email
          
          if approval_status == "approved"
            success_flag = Fax.send_fax(letter_url, to_fax_number, from,
                                        source_method, from_email)
          end
          
          Fax.create!(number_fax: to_fax_number,
                      sender: sender,
                      recipient: recipient,
                      approval_status: approval_status,
                      letter_url: letter_url,
                      letter: letter,
                      success: success_flag,
                      payment: payment_id)
          
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
      params.require(:sender).permit(
        :name, :email, :zipcode, :county, :district, :state, :signature
      )
    end

    def letter_params
      
      # "id": "1", "category": "bakeries",
      # "sentiment": "Very Supportive", "policy_or_law": "deserts"
      params.require(:letter).permit(:id, :category,
                                     :sentiment, :policy_or_law)
    end

    def send_email(name, email)
      # https://developers.clicksend.com/docs/rest/v3/#send-email
      return false
    end    
    
end
