class UsersController < ApplicationController
before_action :require_user, only: [:show]

  def new
    @user = User.new
  end

  def new_with_invitation_token
    @invitation = Invitation.find_by(token: params[:token])
    if @invitation
      @user = User.new(full_name: @invitation.recipient_name, 
                     email: @invitation.recipient_email)
      @invitation_token = @invitation.token
      render :new
    else
      redirect_to expired_token_path
    end
    
  end

  def create
    @user = User.new(user_params)
    if @user.valid?
      registration = UserRegistration.create(@user, params)
      if registration.charge.successful?
        flash[:success] = "You registered! Welcome, #{params[:user][:full_name]}!"
        redirect_to login_path
      else
        flash[:danger] = registration.charge.error_message
        render :new
      end
    else
      render :new
    end
  end

  def show
    @user = User.find(params[:id])
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :full_name)
  end
end