class HomeController < ApplicationController
  def index
    @payments = Payment.get_all(params[:paid], params[:not_paid])
    @users = User.find(:all, :order => 'name ASC')
  end
end
