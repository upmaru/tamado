class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :authenticate_user!

  helper_method :current_user

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def authenticate_user!
    redirect_to new_auth_session_path, alert: "Please log in to continue." unless current_user
  end

  def sign_in(user)
    reset_session
    session[:user_id] = user.id
  end

  def sign_out
    reset_session
  end
end
