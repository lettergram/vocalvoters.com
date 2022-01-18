require 'clicksend_client'

class Fax < CommunicationRecord

  def self.send_fax(letter_url, to_fax_number, from, source_method, from_email)
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
            "from_email": from_email
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

end
