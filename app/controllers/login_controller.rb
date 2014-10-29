class LoginController < ApplicationController
  def index
    @fu = session[:forwarding_url]
    render :layout => 'login'
  end
end
