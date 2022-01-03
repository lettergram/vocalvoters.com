class AccountActivationsController < ApplicationController

  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in user
      flash[:success] = "Account activated!"
      if params[:invite]
        redirect_to edit_user_path(user)
      else
        redirect_to user
      end
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
  
end
