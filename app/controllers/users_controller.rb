class UsersController < ApplicationController
  layout "main"

  before_filter :is_admin

  def index
    @users = User.find(:all, :conditions => ["deleted = 'false'"])
  end

  def show
  end

  def new
    @user = User.new
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(params[:user])

    if @user.save
      flash[:notice] = "#{I18n.t("user.user")} #{@user.name} #{I18n.t("user.was_successfully_created")}."
      redirect_to :action => "index"
    else
      render :action => "new"
    end
  end

  def update
    @user = User.find(params[:id])

    if @user.update_attributes(params[:user])
      set_up_user_session(@user.id) if @session.user == @user
      redirect_to :controller => "users"
    else
      render :action => "edit"
    end
  end

  def delete
    @user = User.find(params[:id])
    
    payments = Payment.all_with_user_component(@user)
    payments.each do |payment|
      value = payment.user_component_value(@user)
      payment.update_user_component_paid(@user, value)
    end

    @user.deleted = true
    @user.save

    redirect_to :controller => "users"
  end

  private

  def is_admin
    unless session[:user_session] && @session.user.admin?
      redirect_to :controller => 'payments'
    end
  end
end
