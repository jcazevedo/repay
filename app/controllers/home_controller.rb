class HomeController < ApplicationController
  def index
    if !request.post?
      params[:paid] = true
      params[:not_paid] = true
    end

    @payments = Payment.get_all(params[:paid], params[:not_paid])
    @users = User.find(:all, :order => 'name ASC')
  end
end
