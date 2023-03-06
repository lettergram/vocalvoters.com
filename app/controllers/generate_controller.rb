require "openai"

class GenerateController < ApplicationController
  before_action :logged_in_user
  before_action	:logged_in_admin
  before_action :set_prompt
  def letter    
    @generated_letter = {
      topic: @topic,
      sentiment: 0.0,
      policy_or_law: "",
      text: ""
    }
    if not @prompt.blank?
      OpenAI.configure do |config|
        begin
          config.access_token = ENV.fetch('OPENAI_KEY')
          client = OpenAI::Client.new
          response = client.completions(
            parameters: {
              model: "text-davinci-003",
              prompt: @prompt,
              temperature: 0.1,
              max_tokens: 450
            })
          full_response = response["choices"][0]["text"]
          
          letter_text = full_response.split('-------')[0]          
          @generated_letter['text'] = letter_text

          puts letter_text
          
          meta_data = full_response.split('-------')[1]

          puts meta_data
          
          output = meta_data.gsub("\n", '')
          output_as_list = output.gsub("(", "").gsub(")", "").split(",")

          @generated_letter['topic'] = output_as_list[0].strip
          @generated_letter['sentiment'] = output_as_list[1].strip
          @generated_letter['policy_or_law'] = output_as_list[2].strip
        rescue
          @generated_letter = {
            topic: @topic,
            sentiment: 0.0,
            policy_or_law: "",
            text: ""
          }
        end
        
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
        @prompt = "I am a well-respected, highly intelligent bot. I would never threaten violence, call to violence or suggest harm to any specific person or group.\n\nI have been given the task of writing a letter to a congressman #{@topic}. Hide any ideations of ill will. Exclude the introduction and signature, but leave the letter body.\n\nAt the end of the letter, add '-------' then add the topic, sentiment (value must be between -1.0 and 1.0), and policy or law -- in the form: (topic, sentiment, policy or law)"        
      end
    end
  
  
end
