class UsersController < ApplicationController
  layout 'main'

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
  end

  def destroy
  end
end
