class UsersController < ApplicationController
  layout "main"

  def index
    @users = User.find(:all)
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
      flash[:notice] = "User #{@user.name} was successfully created."
      redirect_to :action => "index"
    else
      render :action => "new"
    end
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
