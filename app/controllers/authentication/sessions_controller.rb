class Authentication::SessiosController < ApplicationController
	skip_before_action :no_login
  def new

  end

  def create
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_url, notice: "Sessión iniciada!"
    else
      flash.now[:alert] = "Nombre de usuario o contraseña invalido"
      render "new"
    end
  end  

  def destroy
    session[:user_id] = nil
    redirect_to root_url, notice: "Logged out!"
  end
end