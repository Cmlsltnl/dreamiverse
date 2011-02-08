class ApplicationController < ActionController::Base
  helper_method :current_user, :add_starlight
  protect_from_forgery

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def add_starlight(entity, amt)
    Starlight.change(entity, amt)
  end
  
  def unique_hit?
    Hit.unique? request.fullpath, request.remote_ip, current_user
  end
  
protected
  def set_current_user(user)
    session[:user_id] = user ? user.id : nil
    @current_user = user
  end

  def require_username
    if !params[:username]
      redirect_to(params.merge(username: current_user.username)) and return if current_user
      redirect_to root_path, :alert => "you must be logged in to access this page." and return
    end
  end

  def require_user
    unless current_user
      redirect_to :root and return
    end
  end
  
  def render_404
    render :file => "#{Rails.public_path}/404.html",  :status => 404
  end
end
