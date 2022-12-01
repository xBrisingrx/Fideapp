module ApplicationHelper
	def format_currency(num)
		number_to_currency(num, {:unit => '', :separator => ',', :delimiter => '.', :precision => 2})
	end

	def active_class(link_path)
	    current_page?(link_path) ? "active" : ""
	end

	def date_format date
		date.strftime('%d-%m-%y')
	end
end
