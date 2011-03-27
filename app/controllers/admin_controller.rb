class AdminController < ApplicationController
  layout 'main'

  def login
    if request.post?
      user = User.authenticate(params[:name], params[:password])
      if user
        set_up_user_session(user.id)
        redirect_to(:controller => 'payments')
      else
        flash.now[:notice] = I18n.t('main.invalid_login')
      end
    end 
  end

  def logout
    delete_user_session
    redirect_to :action => 'login'
  end
end
