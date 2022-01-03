class UserMailer < ApplicationMailer

  def account_activation(user, inviting_user)
    @user = user
    @invite = inviting_user
    mail to: user.email, subject: "Account activation"
  end

  def password_reset(user)
    @user = user
    mail to: user.email, subject: "Password reset"    
  end  
  
end
