class LettersController < ApplicationController
  before_action :logged_in_user, except: [:show, :selection, :find_policy, :copy_and_update_body]
  before_action	:logged_in_admin, only: [:destroy]
  before_action :set_letter, only: [:show, :edit, :update, :destroy]
  before_action :validate_org_or_admin, except: [:show, :new, :create, :update, :find_policy, :copy_and_update_body, :index, :selection]
  before_action :recipient_position_list, only: [:new, :edit]
  skip_before_action :verify_authenticity_token, only: [:copy_and_update_body]

  # GET /letters
  # GET /letters.json
  def index
    if current_user.admin?
      @letters = Letter.where(derived_from: nil).order(created_at: :desc)
    else 
      @letters = Letter.where(organization: current_user.organization)
                   .where(derived_from: nil).order(created_at: :desc)
    end
  end

  # GET /letters/1
  # GET /letters/1.json
  # GET /letters/1.pdf
  def show

    @template = false
    if params.has_key?(:template)
      @template = true
    end

    @sentiment = @letter.sentiment_in_text()

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

      @sender_state = params[:sender_state]
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
      else
        @sender_region = ""
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
        @sender_region_verified += "Verified "
      else
        @sender_region_verified += "Not Verifiably "
      end
      @sender_region_verified += "in District via Billing Address"
      @sender_region_verified += "</small></i>"
    end

    @sender_address_line_1 = ""
    @sender_address_line_2 = ""
    @sender_address_city = ""
    @sender_address_zipcode = ""
    if params.has_key?(:sender_address_line_1)
      @sender_address_line_1 = params[:sender_address_line_1]
    end
    if params.has_key?(:sender_address_line_2)
      @sender_address_line_2 = params[:sender_address_line_2]
    end
    if params.has_key?(:sender_address_city)
      @sender_address_city = params[:sender_address_city]
    end
    if params.has_key?(:sender_address_zipcode)
      @sender_address_zipcode = params[:sender_address_zipcode]
    end
    
    respond_to do |format|
      format.html
      format.json
      format.pdf do
        render template: "/letters/letter", pdf: "Letter ID: #{@letter.id}", layout: 'pdf'
      end
    end

  end

  # GET /letters/new
  def new
    @letter = Letter.new    
    @targeted_positions = @recipient_position_list
  end

  # GET /letters/1/edit
  def edit
    if @letter.target_positions.present?
      @targeted_positions = @letter.target_positions
    else
      @targeted_positions = @recipient_position_list
    end
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
        puts "\n\n"
        puts params[:target_position]
        puts "\n\n"
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

  def copy_and_update_body
    if params.has_key?(:derived_from)
      @letter = Letter.where(id: params[:derived_from]).first
      @letter_copy = @letter.dup
      @letter_copy.save
      
      respond_to do |format|
        if @letter_copy.update(derived_from: params[:derived_from],
                               category: params[:category],
                               sentiment: params[:sentiment],
                               body: params[:body],
                               email: params[:email])
          format.json { render :copy_and_update_body, status: :created }
        else
          format.json { render json: @letter_copy.errors, status: :unprocessable_entity }
        end
      end  
    end
  end

  # Search /find_policy.json
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

  def selection
    org_id = params[:org_id]
    @letters = Letter.where(organization: org_id)
                 .where(derived_from: nil)
                 .where(promoted: true)
                 .order(created_at: :desc)
    respond_to do |format|
      format.html {
        if params[:layout] == 'false'
          render :layout => false
        end
      }
      format.json
    end

  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_letter
      @letter = Letter.find(params[:id])
    end

    def validate_org_or_admin
      if current_user.present?
        current_user.organization != @letter.organization and !current_user.admin
      end
    end

    # Only allow a list of trusted parameters through.
    def letter_params
      params.require(:letter)
        .permit(:category, :policy_or_law, :tags, :sentiment, :body,
                :target_level, :target_state, :editable, :email, :promoted,
                :target_positions => [])
        .merge(user_id: current_user.id)
        .merge(organization_id: current_user.organization.id)
    end

    def recipient_position_list
      @recipient_position_list = Recipient.distinct.pluck(:position)
    end

end
