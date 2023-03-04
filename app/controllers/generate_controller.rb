require "openai"

class GenerateController < ApplicationController
  before_action :logged_in_user
  before_action	:logged_in_admin
  before_action :set_prompt
  def letter    
    @generated_letter = {
      support: @support,
      topic: @topic,
      text: ""
    }
    if not @prompt.blank?
      OpenAI.configure do |config|
        config.access_token = ENV.fetch('OPENAI_KEY')
        client = OpenAI::Client.new
        response = client.completions(
          parameters: {
            model: "text-davinci-003",
            prompt: @prompt,
            temperature: 0.1,
            max_tokens: 250
          })
        @generated_letter['text'] = response["choices"][0]["text"]
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
      @support = ""
      if(params.has_key?(:support) && params.has_key?(:topic))
        @support = params[:support]
        @topic = params[:topic]
        @prompt = "Write a professional letter, omitting any calls to violence, to a congress person #{@support} of #{@topic}, exclude the introduction and signature, but leave the letter body"
      end
    end
  
  
end
