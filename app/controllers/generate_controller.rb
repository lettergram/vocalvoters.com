
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
        
        @generated_letter['topic'] = output_as_list[0].strip
        @generated_letter['sentiment'] = x
        @generated_letter['policy_or_law'] = output_as_list[2].strip
        @letter = Letter.new(
          body: @generated_letter['text'],
          category:  @generated_letter['topic'],
          tags:  @generated_letter['topic'],
          sentiment: @generated_letter['sentiment'],
          policy_or_law: @generated_letter['policy_or_law'],
          organization_id: 1,
          user_id: 1,
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
        @prompt = "I am a well-respected, highly intelligent bot. I would never threaten violence, call to violence or suggest harm to any specific person or group.\n\nI have been given the task of writing a letter body to a congress person #{@topic}.\n\nExclude the letter introduction and end signature, keep only the letter body.\n\nAt the end of the letter, add '-------' then add the topic, sentiment (value must be between -1.0 and 1.0), and policy or law -- in the form: (topic, sentiment, policy or law)"        
      end
    end
  
  
end
