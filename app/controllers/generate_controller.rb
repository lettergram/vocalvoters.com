
require "openai"

class GenerateController < ApplicationController
  # before_action :logged_in_user
  #  before_action	:logged_in_admin
  before_action :set_prompt
  def letter    
    @generated_letter = {
      topic: @topic,
      sentiment: 0.0,
      policy_or_law: "",
      text: "",
      letter_id: nil
    }
    if not @prompt.blank?
      OpenAI.configure do |config|
        
        config.access_token = ENV.fetch('OPENAI_KEY')
        client = OpenAI::Client.new
        response = client.chat(
          parameters: {
            model: "gpt-3.5-turbo",
            messages: [{ role: "user", content: @prompt }],
            temperature: 0.2,
            max_tokens: 450
          }
        )
        full_response = response.dig("choices", 0, "message", "content")
        
        letter_text = full_response.split('-------')[0]
        
        # Remove any start of letter
        letter_text = letter_text.gsub(/^(dear|Dear)(?<=(Dear|dear))(.*)(?=\n\n)\n\n/, '')
        letter_text = letter_text.split(/^(sincerely|Sincerely)(?<=(sincerely|Sincerely))(.*)(?=\n\n)\n\n/)[0]
        letter_text = letter_text.strip

        # Remove any end of letter
        @generated_letter['text'] = letter_text
        
        meta_data = full_response.split('-------')[1]
        
        output = meta_data.gsub("\n", '')
        output_as_list = output.gsub("(", "").gsub(")", "").split(",")

        x = output_as_list[1].strip.to_f
        if (x > 0.75)
          x = 1.0
        elsif (x > 0.25)
          x = 0.5
        elsif (x > -0.25)
          x = 0
        elsif (x > -0.75)
          x = -0.5
        else
          x = -1.0
        end

        @organization_id = 1
        if params.has_key?(:organization_id)
          @organization_id = params[:organization_id]
        end
        @user_id = 1
        if params.has_key?(:user_id)
          @user_id = param[:user_id]
        end
        
        @generated_letter['topic'] = output_as_list[0].strip
        @generated_letter['sentiment'] = x
        @generated_letter['policy_or_law'] = output_as_list[2].strip
        @letter = Letter.new(
          body: @generated_letter['text'],
          category:  @generated_letter['topic'],
          tags:  @generated_letter['topic'],
          sentiment: @generated_letter['sentiment'],
          policy_or_law: @generated_letter['policy_or_law'],
          target_positions: ["all"],
          organization_id: @organization_id,
          user_id: @user_id,
        )
        @letter.save
        @generated_letter['letter_id'] = @letter.id
      end
    end
    
    respond_to do |format|
      format.html
      format.json { render json: @generated_letter }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_prompt
      @prompt = nil
      @topic = ""
      if params.has_key?(:topic)
        @topic = params[:topic]        
        @prompt = "You are a well-respected, highly intelligent humans.\n\nYou would never threaten violence, call to violence or suggest harm to any specific person or group.\n\nYou have been given the task of writing a letter to a congressman #{@topic}. Hide any ideations of ill will. Exclude the introduction and signature, but leave the letter body.\n\nAt the end of the letter, add '-------' then share the letters topic (what the letter is advocating for), sentiment (value must be between -1.0 and 1.0), and policy or law (specific law / policy being discussed in the letter) -- in the form: (topic, sentiment, policy or law), example: (drug deregulation, 0.75, H.R. 815)"
      end
    end
  
  
end
