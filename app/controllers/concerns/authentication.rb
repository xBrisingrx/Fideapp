module Authentication 
	extend ActiveSupport::Concern

	included do
		helper_method :current_user, :logged_in?
		before_action :set_current_user, :no_login

		def current_user
	    if session[:user_id]
	      @current_user ||= User.find_by_id(session[:user_id])
	    else
	      @current_user = nil
	    end
	  end

	  def set_current_user
	  	Current.user = User.find_by(id: session[:user_id]) if session[:user_id]
	  end

	  def logged_in?
	    !!current_user
	  end
	end

	private
	def no_login
    if !logged_in?
      redirect_to login_path
    end
  end 
end