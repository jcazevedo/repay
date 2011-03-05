class UsersController < ApplicationController
  layout "main"

  def index
    @users = User.find(:all)
  end

  def show
  end

  def new
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
  end

  def update
    @user = User.find(params[:id])

    if @user.update_attributes(params[:user])
      set_up_user_session(@user.id)
      redirect_to :controller => "payments"
    else
      render :action => "edit"
    end
  end

  def destroy
  end
end
