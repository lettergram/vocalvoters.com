class SendersController < ApplicationController
  before_action :logged_in_user, except: [:new, :create]
  before_action :logged_in_admin, except: [:new, :create]
  before_action :set_sender, only: [:show, :edit, :update, :destroy]

  # GET /senders
  # GET /senders.json
  def index
    @senders = Sender.all
  end

  # GET /senders/1
  # GET /senders/1.json
  def show
  end

  # GET /senders/new
  def new
    @sender = Sender.new
  end

  # GET /senders/1/edit
  def edit
  end

  # POST /senders
  # POST /senders.json
  def create
    @sender = Sender.find_by(
      :name => sender_params[:name],
      :email => sender_params[:email],
      :zipcode => sender_params[:zipcode],
      :county => sender_params[:county],
      :district => sender_params[:district],
      :state => sender_params[:state],
      :signature => sender_params[:signature])
    
    if not @sender.present?
      @sender = Sender.new(sender_params)
      respond_to do |format|
        if @sender.save
          format.html { redirect_to @sender, notice: 'Sender was successfully created.' }
          format.json { render :json => @sender.id }
        else
          format.html { render :new }
          format.json { render json: @sender.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to @sender, notice: 'Sender already existed.' }
        format.json { render :json => @sender.id }
      end
    end
  end

  # PATCH/PUT /senders/1
  # PATCH/PUT /senders/1.json
  def update
    respond_to do |format|
      if @sender.update(sender_params)
        format.html { redirect_to @sender, notice: 'Sender was successfully updated.' }
        format.json { render :show, status: :ok, location: @sender }
      else
        format.html { render :edit }
        format.json { render json: @sender.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /senders/1
  # DELETE /senders/1.json
  def destroy
    @sender.destroy
    respond_to do |format|
      format.html { redirect_to senders_url, notice: 'Sender was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sender
      @sender = Sender.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def sender_params
      params.require(:sender)
        .permit(:name, :email, :zipcode, :county, :district, :state, :signature)
    end
end
