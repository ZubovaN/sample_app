class UsersController < ApplicationController
  #вызовем метод logged_in_user через before_action :logged_in_user
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy]

  def index
    # применяется пагинация
    # params[:page] - номер запрашиваемой страницы которую получаем из парамс
    # метод will_paginate сам генерирует params[:page]
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(permitted_params)
    if @user.save
      flash[:success] = "Welcome to the Sample App!"
      log_in @user
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @user.update_attributes(permitted_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted!"
    redirect_to users_url
  end

  private

  def permitted_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  # Подтверждает вход пользователя.
  def logged_in_user
    unless logged_in?
      store_location

      flash[:danger] = "Please log in!"
      redirect_to login_path
    end
  end

  # Подтверждает права пользователя, юзер не может редактировать и обновлять других юзеров
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

  def admin_user
    redirect_to root_url unless current_user.admin?
  end
end
