class Auth::RegistrationsController < ApplicationController
  skip_before_action :authenticate_user!

  def new
    redirect_to projects_path if current_user
    @user = User.new
  end

  def create
    @user = User.new(signup_params)

    if @user.save
      sign_in(@user)
      redirect_to projects_path, notice: "Welcome, #{@user.email}!"
    else
      flash.now[:alert] = @user.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  private

  def signup_params
    params.expect(user: %i[email password password_confirmation])
  end
end
