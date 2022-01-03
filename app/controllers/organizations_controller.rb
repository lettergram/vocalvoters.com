class OrganizationsController < ApplicationController
  before_action :logged_in_user, only: [:show]
  before_action :logged_in_admin, except: [:show]
  before_action :set_organization, only: [:show, :edit, :update, :destroy, :remove_user_from_org]
  before_action :logged_in_org_admin, only: [:show]

  # GET /organizations
  # GET /organizations.json
  def index
    @organizations = Organization.all
  end

  # GET /organizations/1
  # GET /organizations/1.json
  def show
    @letters = Post.left_outer_joins(:letter).where('organization_id = ?', @organization.id)
                 .group(:category, :policy_or_law, :sentiment)
    
    @letters_by_month = map_for_letters(
      @letters.group_by_month(:created_at, format: "%Y-%m-%d").count)
    
    @letters_by_day = map_for_letters(
      @letters.group_by_day(:created_at, format: "%Y-%m-%d").count)

    @letters_by_day_of_week = map_for_letters(
      @letters.group_by_day_of_week(:created_at, format: "%a").count)    
    
    @letters_by_state = map_for_letters(
      @letters.group(:address_state).count)

    @letters_by_target_level = map_for_letters(
      @letters.group(:target_level).count)

    @letters_by_type = @letters.count
    
  end

  # GET /organizations/new
  def new
    @organization = Organization.new
  end

  # GET /organizations/1/edit
  def edit
  end

  # POST /organizations
  # POST /organizations.json
  def create
    @organization = Organization.new(organization_params)

    respond_to do |format|
      if @organization.save
        format.html { redirect_to @organization, notice: 'Organization was successfully created.' }
        format.json { render :show, status: :created, location: @organization }
      else
        format.html { render :new }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /organizations/1
  # PATCH/PUT /organizations/1.json
  def update
    respond_to do |format|
      if @organization.update(organization_params)
        format.html { redirect_to @organization, notice: 'Organization was successfully updated.' }
        format.json { render :show, status: :ok, location: @organization }
      else
        format.html { render :edit }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organizations/1
  # DELETE /organizations/1.json
  def destroy
    @organization.destroy
    respond_to do |format|
      format.html { redirect_to organizations_url, notice: 'Organization was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def remove_user_from_org
    
    respond_to do |format|
      if params.has_key?(:user_id)
        user = User.find(params[:user_id])
        
        user.organization_id = nil # Remove user from organization
        user.org_admin = false
        user.save!
        
        format.html {
          redirect_to @organization,
          notice: 'Organization was successfully updated, removed user: ' + user.email
        }
        format.json { render :show, status: :ok, location: @organization }
      else
        format.html { render @organization, notice: 'Organization not updated.' }
        format.json { render json: @organization.errors, status: :unprocessable_entity }
      end
    end
  end
  
  private
  
    # Use callbacks to share common setup or constraints between actions.
    def set_organization
      @organization = Organization.find(params[:id])
    end


    def logged_in_org_admin
      
      if !current_user or !current_user.org_admin or current_user.organization.id != @organization.id
        flash[:warning] = "Only organization administrators can view that information."
        redirect_back(fallback_location: root_path)
      end          
    end
        
    # Only allow a list of trusted parameters through.
    def organization_params
      params.require(:organization).permit(:name, :description, :approvals_required)
    end

    def sentiment_to_text(sentiment)
      
      sentiment = sentiment.to_f
      
      if sentiment > 0.5
        return 'strongly support'
      elsif sentiment > 0
        return 'support'
      elsif sentiment == 0
        return 'am indifferent to'
      elsif sentiment < -0.5
        return 'strongly oppose'
      elsif sentiment < 0
        return 'oppose'
      end
      
    end

    def map_for_letters(form_letters_by_category)
      letters_by_category = {}
      form_letters_by_category.map { |form_letter|
        [
	  sentiment_to_text(form_letter[0][2])+" "+form_letter[0][0]+" "+form_letter[0][1],
          form_letter[0][3], form_letter[1]
        ]
      }.each { |form_letter|
        if not letters_by_category.has_key? form_letter[0]
          letters_by_category[form_letter[0]] = {}
        end
        letters_by_category[form_letter[0]][form_letter[1]] = form_letter[2]
      }
      
      letters_by_category = letters_by_category.map { |key, value|
        { name: key, data: value }
      }
      
      return letters_by_category
    end
    
end
