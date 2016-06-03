class ApplicationController < ActionController::Base
  protect_from_forgery
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def authenticated?
    if session[:user_email].blank?
      return false
    end

    if session[:user_auth].blank?
      user = Student.where("(email = ? OR email_cimav = ?) AND status in (1,6)",session[:user_email], session[:user_email]).first
      session[:user_auth] = user && ( user.email == session[:user_email] || user.email_cimav == session[:user_email])
      if session[:user_auth]
        session[:user_id] = user.id
      end
    else
      session[:user_auth]
    end
  end
  helper_method :authenticated?

  def auth_required
    store_location
    redirect_to '/login' unless authenticated?
  end

  helper_method :current_user

  def store_location
    session[:forwarding_url] = request.url if request.get?
  end

  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

private
def current_user
  @current_user ||= Student.find(session[:user_id]) if session[:user_id]
end

end
