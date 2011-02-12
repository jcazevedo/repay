# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  before_filter :authorize, :except => :login
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery :secret => '10271e900b8541f58c4bead9ca2a86b8'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password

  protected

  # Sets up a new UserSession from a given user_id.
  def set_up_user_session(user_id)
    session[:user_session] = UserSession.new
    session[:user_session].user = User.find(user_id)
    session[:user_session].paid = false
    session[:user_session].not_paid = true
  end

  # Deletes the current UserSession.
  def delete_user_session
    session[:user_session] = nil
  end

  # Returns the currently logged in User.
  def current_user
    return session[:user_session].user if !session[:user_session].nil?
  end

  # Defines whether or not paid Payments shall be loaded.
  def load_paid_payments?
    return session[:user_session].paid == true
  end

  # Defines whether or not not paid Payments shall be loaded.
  def load_not_paid_payments?
    return session[:user_session].not_paid == true
  end

  # Defines redirection based on the login status.
  def authorize
    unless user_logged_in?
      flash[:notice] = "Please log in"
      redirect_to :controller => 'admin', :action => 'login'
    end
  end

  # Returns true if there is a user logged in, false otherwise.
  def user_logged_in?
    return !session[:user_session].nil? && !session[:user_session].user.nil?
  end
end
