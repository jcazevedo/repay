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
  end

  def update
  end

  def destroy
  end
end
