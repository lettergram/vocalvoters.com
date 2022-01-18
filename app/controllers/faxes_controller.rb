class FaxesController < ApplicationController  
  before_action :logged_in_user, except: [:new, :create]
  before_action	:logged_in_admin, except: [:new, :create]
  before_action :set_fax, only: [:show, :edit, :update, :destroy]

  # GET /faxes
  # GET /faxes.json
  def index
    @faxes = Fax.order(created_at: :desc).all                          
               .paginate(page: params[:page]) # Will have to modify
  end

  # GET /faxes/1
  # GET /faxes/1.json
  def show
  end

  # GET /faxes/new
  def new
    @fax = Fax.new
  end

  # GET /faxes/1/edit
  def edit
  end

  # POST /faxes
  # POST /faxes.json
  def create
    @fax = Fax.new(fax_params)

    respond_to do |format|
      if @fax.save
        format.html { redirect_to @fax, notice: 'Fax was successfully created.' }
        format.json { render :show, status: :created, location: @fax }
      else
        format.html { render :new }
        format.json { render json: @fax.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /faxes/1
  # PATCH/PUT /faxes/1.json
  def update

    # Change in approval status and not "pending" 
    approval_flag = @fax.approval_status != fax_params['approval_status'] and
      fax_params['approval_status'] != 'pending'
    
    respond_to do |format|
      if @fax.update(fax_params) # approved update        
        if approval_flag
          if @fax.approval_status == "approved"
            
            success = Fax.send_fax(
              @fax.letter_url, @fax.number_fax,
              "from", "VocalVoters", @fax.sender.email)            
            @fax.update!(success: success)
            
            if success # If successsful remove letter_url
              @fax.update!(letter_url: nil) 
            end
            
            flash[:success] = 'Successfully Approved Fax - Sending!'
          elsif @fax.approval_status = "declined"
            @fax.update!(letter_url: nil) # Remove, as decided
            flash[:danger] = 'Declined Sending Fax'
          end          
        end
        
        format.html { redirect_back(fallback_location: @fax) }
        format.json { render :show, status: :ok, location: @fax }
      else
        format.html { render :edit }
        format.json { render json: @fax.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /faxes/1
  # DELETE /faxes/1.json
  def destroy
    @fax.destroy
    respond_to do |format|
      format.html { redirect_to faxes_url, notice: 'Fax was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_fax
      @fax = Fax.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def fax_params
      params.require(:fax).permit(:approval_status,
        :number_fax, :sender_id, :recipient_id, :letter_id, :payment_id)
    end
end
