class HomeController < ApplicationController
  before_filter :load_users, :load_payments

  def load_users
    @users = User.find(:all, :order => 'name ASC')
  end

  def load_payments
    if !request.post?
      params[:paid] = true
      params[:not_paid] = true
    end

    @payments = Payment.get_all(params[:paid], params[:not_paid])
  end

  def index
    @payment = Payment.new
  end
  
  def save_payment
    @payment = Payment.new(params[:payment])
    if @payment.save
      redirect_to :action => 'index'
    else
      render :action => 'index'
    end
  end
end
