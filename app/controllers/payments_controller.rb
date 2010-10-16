class PaymentsController < ApplicationController
  def show
    @payment = Payment.find(params[:id])
  end

  def new
    @payment = Payment.new
    @users = Payment.find_all
  end

  def edit
    @payment = Payment.find(params[:id])
  end

  def create
  end

  def update
  end

  def destroy
  end

end
