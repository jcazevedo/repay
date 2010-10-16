class AdminController < ApplicationController
  def login
    if request.post?
      user = User.authenticate(params[:name], params[:password])
      if user
        session[:user_id] = user.id
        redirect_to(:controller => "home")
      else
        flash.now[:notice] = "Invalid user/password combination"
      end
    end 
  end

  def logout
  end

end
