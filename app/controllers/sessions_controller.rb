class SessionsController < ApplicationController
  def create
    session[:user_email] = auth_hash['info']['email']

    if authenticated?
      redirect_back_or '/'
    else
      render :text => '401 Unauthorized', :status => 401
    end
  end

  def destroy
    if session[:forwarding_url]
      logger.info "La sesion antes del destroy es: #{session[:forwarding_url]}"
      @rescue_fu = session[:forwarding_url] 
    end
    reset_session
    session[:forwarding_url] = @rescue_fu
    redirect_to '/login'
  end

  def failure
    render :text => '403 Auth method has failed', :status => 403
  end

  protected
  def auth_hash
    request.env['omniauth.auth']
  end
end
