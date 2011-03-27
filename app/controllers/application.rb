# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  before_filter :authorize, :except => :login
  before_filter :load_session
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery :secret => '10271e900b8541f58c4bead9ca2a86b8'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password

  protected

  def set_up_user_session(user_id)
    session[:user_session] = UserSession.new
    session[:user_session].user = User.find(user_id)
    session[:user_session].paid = false
    session[:user_session].not_paid = true
  end

  def delete_user_session
    session[:user_session] = nil
  end

  def update_load_paid_flag(new_flag_value)
    session[:user_session].paid = new_flag_value
  end

  def update_load_not_paid_flag(new_flag_value)
    session[:user_session].not_paid = new_flag_value
  end

  def authorize
    unless user_logged_in?
      flash[:notice] = "Please log in"
      redirect_to :controller => 'admin', :action => 'login'
    end
  end

  def load_session
    User.current_session = session[:user_session]
    @session = User.current_session
  end

  def load_not_paid_payments?
    return session[:user_session].load_not_paid?
  end

  def load_paid_payments?
    return session[:user_session].load_paid?
  end

  private

  def user_logged_in?
    return !session[:user_session].nil?
  end
end
