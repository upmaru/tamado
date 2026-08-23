class Auth::SessionsController < ApplicationController
  skip_before_action :authenticate_user!

  def new
    redirect_to projects_path if current_user
  end

  def create
    email, password = params.expect(session: %i[email password]).values_at(:email, :password)
    user = User.find_by(email: email.to_s.strip.downcase)

    if user&.authenticate(password.to_s)
      sign_in(user)
      redirect_to projects_path, notice: "Welcome back!"
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    sign_out
    redirect_to new_auth_session_path, notice: "You have been signed out."
  end
end
