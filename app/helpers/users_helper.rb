module UsersHelper

  # Confirms an admin user.
  def admin_user
    unless current_user.admin?
      store_location
      flash[:danger] = "Inappropriate permissions."
      redirect_to root_url
    end
  end

  # Disables access to other users, unless site admin
  # Fail with no error message
  # TODO: Send to 404 page
  def logged_in_admin
    if params.has_key?(:id) and params[:controller] == "user"
      # If has id tag, check current user or admin user, if not -> redirect   
      if (current_user != User.find(params[:id]) && !current_user.admin?)
        redirect_to root_url
      end
    else
      # If no id tag, check if admin, if not -> redirect   
      if !current_user or !current_user.admin?
        flash[:warning] = "Only administrators can view that information, contact us."
        redirect_back(fallback_location: root_path)
      end
    end
  end
  
  # Find user by token                   
  def find_user_from_auth_token
    authenticate_with_http_token do |token, options|
      api_key = ApiKey.find_by_access_token(token)
      if api_key.present?
        @user = User.find_by_id(api_key.user_id)
        return true
      end
    end
    return false
  end  
  
end
