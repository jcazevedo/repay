class HomeController < ApplicationController
  def index
    @payments = Payment.find(:all, :order => 'created_at DESC')
    @users = User.find(:all, :order => 'name ASC')
  end
end
