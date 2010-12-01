class HomeController < ApplicationController
  before_filter :check_filters, :load_users, :load_payments

  def check_filters
    if !request.post?
      params[:paid] = "true"
      params[:not_paid] = "true"
    end
    params[:paid] = nil if params[:paid] != "true"
    params[:not_paid] = nil if params[:not_paid] != "true"
  end

  def load_users
    @users = User.find(:all, :order => 'name ASC')
  end

  def load_payments
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

  def update_payment
    @payment = Payment.find(params[:id])
    if @payment.update_attributes(params[:payment])
      redirect_to :action => 'index'
    else
      render :action => 'index'
    end
  end
end
