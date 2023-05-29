class ApplicationController < ActionController::Base
	include Authentication
  include Authorization
  include Language
end
