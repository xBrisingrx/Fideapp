module Authorization 
	extend ActiveSupport::Concern

	included do
			class NotAuthorizedError < StandardError; end 

			rescue_from NotAuthorizedError do 
				redirect_to votes_path
			end
	end

	private
	def authorize! record = nil
    # is_allowed = "#{controller_name.singularize}Policy".classify.constantize.new(record).send(action_name)
    controller = "#{controller_name.singularize}".classify
    is_allowed = "#{controller}Policy".constantize.new(record).send(action_name)
    raise NotAuthorizedError unless is_allowed
  end
end