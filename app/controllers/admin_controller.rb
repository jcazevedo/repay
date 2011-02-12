class AdminController < ApplicationController
  layout 'home'

  def login
    if request.post?
      user = User.authenticate(params[:name], params[:password])
      if user
        set_up_user_session(user.id)
        redirect_to(:controller => "home")
      else
        flash.now[:notice] = "Invalid user/password combination"
      end
    end 
  end

  def logout
    delete_user_session
    redirect_to :action => 'login'
  end
end
