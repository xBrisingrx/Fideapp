class ApplicationController < ActionController::Base
	around_action :switch_locale
  helper_method :current_user, :logged_in?
  before_action :no_login

  def switch_locale(&action)
    I18n.with_locale(locale_from_header, &action)
  end

  def current_user
    if session[:user_id]
      @current_user ||= User.find(session[:user_id])
    else
      @current_user = nil
    end
  end

  def logged_in?
    !!current_user
  end

  private

  def locale_from_header # obtenemos el lenguaje desde la cabecera de la peticion
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
  end

  def no_login
    if !logged_in?
      redirect_to login_path
    end
  end
end
