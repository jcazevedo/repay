class HomeController < ApplicationController
  before_filter :load_users, :load_payments

  def update_filters
    update_load_paid_flag(params[:paid] || false)
    update_load_not_paid_flag(params[:not_paid] || false)

    redirect_to :action => 'index'
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

    params[:payment_components].each do |id, val|
      # TODO: hide this logic
      @pc = @payment.payment_components.find_by_user_id(id)
      @pc.update_attributes(val)
    end

    if @payment.update_attributes(params[:payment])
      redirect_to :action => 'index'
    else
      render :action => 'index'
    end
  end
  
  def update_amount
    current_user = User.current_session.user
    user = User.find(params[:user])
    amount = params[:value].to_f

    if user && amount
      user.update_amount(current_user, amount)
    end

    redirect_to :action => 'index' 
  end

  private

  def load_users
    @users = User.find(:all, :order => 'name ASC')
  end

  def load_payments
    @payments = []
    @payments += Payment.all_not_paid if load_not_paid_payments?
    @payments += Payment.all_paid if load_paid_payments?
  end
end
