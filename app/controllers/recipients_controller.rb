require 'net/http'
class RecipientsController < ApplicationController
  before_action :logged_in_user, except: [:show, :lookup]
  before_action :logged_in_admin, except: [:show, :lookup]
  before_action :set_recipient, only: [:show, :edit, :update, :destroy]

  # GET /recipients
  # GET /recipients.json
  def index
    @recipients = Recipient.all
  end

  # GET /recipients/1
  # GET /recipients/1.json
  def show
  end

  # GET /recipients/new
  def new
    @recipient = Recipient.new
  end

  # GET /recipients/1/edit
  def edit
  end

  # POST /recipients
  # POST /recipients.json
  def create
    @recipient = Recipient.new(recipient_params)

    respond_to do |format|
      if @recipient.save
        format.html { redirect_to @recipient, notice: 'Recipient was successfully created.' }
        format.json { render :show, status: :created, location: @recipient }
      else
        format.html { render :new }
        format.json { render json: @recipient.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /recipients/1
  # PATCH/PUT /recipients/1.json
  def update
    respond_to do |format|
      if @recipient.update(recipient_params)
        format.html { redirect_to @recipient, notice: 'Recipient was successfully updated.' }
        format.json { render :show, status: :ok, location: @recipient }
      else
        format.html { render :edit }
        format.json { render json: @recipient.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /recipients/1
  # DELETE /recipients/1.json
  def destroy
    @recipient.destroy
    respond_to do |format|
      format.html { redirect_to recipients_url, notice: 'Recipient was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /govlookup
  # GET /govlookup.json
  def lookup
    
    obj = get_congressional_districts()

    @address_accuracy = obj['results'][0]['accuracy']

    if @address_accuracy > 0.7
      @accuracy_class = ""
    elsif @address_accuracy > 0.5
      @accuracy_class = "moderate-risk-highlight"
    else
      @accuracy_class = "high-risk-highlight"
    end
        
    district_info = obj['results'][0]['fields']['congressional_districts'][0]      
    district_number = district_info['district_number']

    @sender_line_1 = ''
    if obj['results'][0]['address_components'].has_key? 'number'
      @sender_line_1 = obj['results'][0]['address_components']['number']
    end
    if obj['results'][0]['address_components'].has_key? 'formatted_street'
      @sender_line_1 += ' ' + obj['results'][0]['address_components']['formatted_street']
    end
    
    @address_line_2 = ''
    if obj['results'][0]['address_components'].has_key? 'secondaryunit'
      @address_line_2 += obj['results'][0]['address_components']['secondaryunit']
    end
    if obj['results'][0]['address_components'].has_key? 'secondarynumber'
      @address_line_2 += ' ' + obj['results'][0]['address_components']['secondarynumber']
    end

    @sender_city = obj['results'][0]['address_components']['city']
    @sender_state = obj['results'][0]['address_components']['state']
    @sender_zipcode = obj['results'][0]['address_components']['zip']
    @sender_country = obj['results'][0]['address_components']['country']

    @sender_address = obj['input']['formatted_address']
    @sender_county = obj['results'][0]['address_components']['county'].sub(/ County/, '')
    @sender_district_federal = district_number
    
    level = 'federal'    
    legislators = district_info['current_legislators']

    @recipients = []    
    for legislator in legislators
      
      position = legislator['type']
      name = legislator['bio']['first_name'] + ' ' + legislator['bio']['last_name']
      number_phone = legislator['contact']['phone'].gsub(/-/, '').to_i
      contact_form = legislator['contact']['url']
      if legislator['contact']['contact_form'].present?
        contact_form = legislator['contact']['contact_form']
      end
      
      address_line_1 = legislator['contact']['address'].split(' Washington')[0]
      address_city = 'Washington'
      address_state = 'DC'
      address_zipcode = legislator['contact']['address'].split(' DC ')[1]

      # Find and use
      recipient = Recipient.find_by(
        :name => name, :position => position, :level => level, :state => @sender_state)
      
      # If cannot find matching record, create new record
      if not recipient.present?      
        recipient = Recipient.create(
          :name => name,
          :position => position,
          :level => level,
          :district => district_number,
          :state => @sender_state,
          :number_phone => number_phone,
          :contact_form => contact_form,
          :address_line_1 => address_line_1,
          :address_city => address_city,
          :address_state => address_state,
          :address_zipcode => address_zipcode)
      end

      if not recipient.retired
        @recipients.push(recipient)
      end
    end

    level = 'state'
    state_district = obj['results'][0]['fields']['state_legislative_districts']

    # Find state govenor 
    recipient = Recipient.find_by(
      :position => 'governor', :state => @sender_state, :retired => false)
    if recipient.present?
      @recipients.push(recipient)
    end

    if state_district.has_key? 'house'
      district = state_district['house']['district_number']    
      @sender_district_representative = district
      recipient = Recipient.find_by(
        :position => 'representative', :district => district,
        :level => level, :state => @sender_state, :retired => false)
      if recipient.present?
        @recipients.push(recipient)
      end
    end

    if state_district.has_key? 'senate'
      district = state_district['senate']['district_number']
      @sender_district_senate = district
      recipient = Recipient.find_by(
        :position => 'senator', :district => district,
        :level => level, :state => @sender_state, :retired => false)
      if recipient.present?
        @recipients.push(recipient)
      end
    end
    
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
    def set_recipient
      @recipient = Recipient.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def recipient_params
      params.require(:recipient).permit(:name, :position, :level, :district, :state, :number_fax, :number_phone, :email_address, :contact_form, :address_line_1, :address_line_2, :address_city, :address_state, :address_zipcode, :retired)
    end

    def get_congressional_districts
      url = 'https://api.geocod.io/v1.6/geocode'
      
      address = ""
      fields = "cd" # congressional district
      fields += ",stateleg" # state congressional district
      api_key = ""
      if ENV.has_key?("GEOCODIO_API_KEY")
        api_key = ENV["GEOCODIO_API_KEY"]
      end
      
      url += '?q=' + params[:address]
      url += '&fields=' + fields
      url += '&api_key=' + api_key
      
      uri = URI(url)
      obj = Net::HTTP.get(uri)

      return ActiveSupport::JSON.decode(obj)
    end
end
