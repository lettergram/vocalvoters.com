class UsersController < ApplicationController
  before_action :logged_in_user,  only: [:index, :edit, :update, :destroy]
  before_action :logged_in_admin, only: [:index, :destroy]
  before_action :correct_user_or_amdin, only: [:edit, :update]
  before_action :admin_user,      only: :destroy
  

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.html
      format.pdf do
        render template: "users/show.html.erb",
               pdf: "User ID: #{@user.id}"
      end
    end
  end

  def new
    @user = User.new
  end

  def create    
    @user = User.new(new_user_params)
    if @user.save
      inviting_user = current_user.present?
      @user.send_activation_email(inviting_user)
      flash[:info] = "Please check email to activate the account."
      redirect_to root_url
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])    
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update(update_user_params)
      flash[:success] = "Profile updated"
      redirect_to @user      
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_back_or_to users_url
  end  
  

  private

    def new_user_params
      if current_user.present?
        params.require(:user).permit(:name, :email, :organization_id, :org_admin)
        
        string_length = 16
        password = rand(36**string_length).to_s(36)
          
        params[:user] = params[:user].merge(:password => password,
                                            :password_confirmation => password)
        
        if current_user.org_admin
          params.require(:user).permit(:name, :email,
                                       :organization_id, :org_admin,
                                       :password, :password_confirmation)
        else
          params.require(:user).permit(:name, :email,
                                       :organization_id,
                                       :password, :password_confirmation)
        end
        
      else
        params.require(:user).permit(:name, :email,
                                     :password, :password_confirmation)
      end
    end
    
    def update_user_params
      if current_user.present?
        if current_user.admin?          
          params.require(:user).permit(:name, :email,
                                       :organization_id, :org_admin,
                                       :password, :password_confirmation)
        else
          params.require(:user).permit(:name, :email,
                                       :password, :password_confirmation)
        end
      end
    end

    # Before filters

    # Confirms a logged-in user.
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end

    # Confirms the correct user.
    def correct_user_or_amdin
      @user = User.find(params[:id])
      if not current_user.admin?
        redirect_to(root_url) unless current_user?(@user)
      end
    end

    # Confirms an admin user.
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
    
end
