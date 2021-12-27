class LettersController < ApplicationController
  before_action :logged_in_user, except: [:show, :find_policy]
  before_action	:logged_in_admin, except: [:show, :find_policy]  
  before_action :set_letter, only: [:show, :edit, :update, :destroy]

  # GET /letters
  # GET /letters.json
  def index
    if current_user.admin?
      @letters = Letter.all
    else 
      @letters = Letter.where(organization: current_user.organization)
    end
  end

  # GET /letters/1
  # GET /letters/1.json
  def show

    @template = false
    if params.has_key?(:template)
      @template = true
    end
    
    if @letter.sentiment > 0.5
      @sentiment = 'strongly support'
    elsif @letter.sentiment > 0
      @sentiment = 'support'
    elsif @letter.sentiment == 0
      @sentiment = 'am indifferent to'
    elsif @letter.sentiment < -0.5
      @sentiment = 'strongly oppose'
    elsif @letter.sentiment < 0
      @sentiment = 'oppose'
    end

    @recipient_name = "[[ insert government official name ]]"
    recipient_name = nil
    if params.has_key?(:recipient_name)
      @recipient_name = params[:recipient_name]
      recipient_name = Recipient.where(name: @recipient_name)
    end
    
    @sender_name = "[[ insert senders name ]]"
    if params.has_key?(:sender_name)
      @sender_name = params[:sender_name]
    end

    @sender_region = ""
    
    if params.has_key?(:sender_county)
      @sender_region += params[:sender_county].downcase.sub(/county/, '').titleize
      @sender_region += ' County'
      if params.has_key?(:sender_state)
        @sender_region += ", "+params[:sender_state]
      end
      @sender_region += '<br>'
    end

    @recipient_position = ""
    if params.has_key?(:recipient_position)
      @recipient_position = params[:recipient_position].titleize
    end    

    recipient_district = nil
    recipient_level = nil
    if params.has_key?(:sender_district)
      @sender_region +=  params[:sender_district].to_i.ordinalize

      recipient_district = Recipient.where(district: params[:sender_district])

      region = " Congressional District"
      level = "United States"
      if params.has_key?(:recipient_level) \
        and params[:recipient_level] == "state"
        if params.has_key?(:recipient_position)
          region = " " + @recipient_position + " District"
        end
        level = "State"
        
        recipient_level = Recipient.where(level: params[:recipient_level])        
      end
      
      @sender_region += region
    end

    @sender_signature = nil
    if params.has_key?(:signature)
      @sender_signature = params[:signature].gsub(' ', '+')
    end

    recipient_state = nil
    if params.has_key?(:sender_state)

      recipient_state = Recipient.where(state: params[:sender_state])
            
      @sender_region += ", " + params[:sender_state]
      if level == "State"
        level = params[:sender_state] + " " + level
      end
    end
    
    @recipient_location = ""
    if @recipient_position.present?
      if @recipient_position == "Senator"
        @recipient_location = level + " Senate"
      elsif @recipient_position == "Representative"
        @recipient_location = level + " House"
      end
    end

    # Select recipient, if possible    
    recipient = Recipient
    if recipient_name.present?
      recipient = recipient.and(recipient_name)
    end
    if recipient_district.present?
      recipient = recipient.and(recipient_district)
    end
    if recipient_level.present?
      recipient = recipient.and(recipient_level)
    end
    if recipient_state.present?
      recipient = recipient.and(recipient_state)
    end
    
    # Ensure only one recipient for accuracy
    @recipient = nil
    if (not recipient.is_a?(Class)) and recipient.length == 1
      @recipient = recipient.first
    end
    

    @sender_region_verified = ""
    if params.has_key?(:sender_verified)
      @sender_region_verified = "<br><i><small>"
      if ActiveModel::Type::Boolean.new.cast(params[:sender_verified])
        @sender_region_verified += "&#10004; Verified "
      else
        @sender_region_verified += "&#10006; Not Verifiably "
      end
      @sender_region_verified += "in District via Billing Address"
      @sender_region_verified += "</small></i>"
    end
    
    respond_to do |format|
      format.html
      format.pdf do
        render template: "letters/letter.html.erb",
               pdf: "Letter ID: #{@letter.id}"
      end
    end    
  end

  # GET /letters/new
  def new
    @letter = Letter.new
  end

  # GET /letters/1/edit
  def edit
  end

  # POST /letters
  # POST /letters.json
  def create
    @letter = Letter.new(letter_params)

    respond_to do |format|
      if @letter.save
        format.html { redirect_to @letter, notice: 'Letter was successfully created.' }
        format.json { render :show, status: :created, location: @letter }
      else
        format.html { render :new }
        format.json { render json: @letter.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /letters/1
  # PATCH/PUT /letters/1.json
  def update
    respond_to do |format|
      if @letter.update(letter_params)
        format.html { redirect_to @letter, notice: 'Letter was successfully updated.' }
        format.json { render :show, status: :ok, location: @letter }
      else
        format.html { render :edit }
        format.json { render json: @letter.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /letters/1
  # DELETE /letters/1.json
  def destroy
    @letter.destroy
    respond_to do |format|
      format.html { redirect_to letters_url, notice: 'Letter was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def find_policy
    category = params[:category]
    sentiment = params[:sentiment]
    policy_or_law = params[:policy_or_law]

    @policy_or_laws = Letter.left_outer_joins(:organization)
    
    if category.present?
      @policy_or_laws = @policy_or_laws.where(
        "category LIKE lower(?)", "%#{category}%")
    end
    if policy_or_law.present?
      @policy_or_laws = @policy_or_laws.where(
        "policy_or_law LIKE lower(?)", "%#{policy_or_law}%")
    end
    if sentiment.present?
      @policy_or_laws = @policy_or_laws.where(sentiment: sentiment.to_f)
    end

    @policy_or_laws = @policy_or_laws.distinct.pluck(
      :id, :sentiment, :category, :policy_or_law, :name)
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_letter
      @letter = Letter.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def letter_params
      params.require(:letter)
        .permit(:category, :policy_or_law, :tags, :sentiment, :body,
                :target_level, :target_state)
        .merge(user_id: current_user.id)
        .merge(organization_id: current_user.organization.id)
    end

end
