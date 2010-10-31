class PaymentsController < ApplicationController
  def show
    @payment = Payment.find(params[:id])
  end

  def new
    @payment = Payment.new
    @users = User.find(:all)
  end

  def edit
    @payment = Payment.find(params[:id])
  end

  def create
    payment = Payment.create(params[:payment])
    current_user = User.find(session[:user_id])
    pc = payment.payment_components.find_by_user_id(current_user)
    if pc
      pc.paid = true
      pc.save
    end
  end

  def update
  end

  def destroy
  end
end
