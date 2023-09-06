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

	def show_owes owes
		if owes != '---'
			"$#{format_currency(owes)}"
		else
			owes
		end
	end

	def class_current_month month
		"g-bg-lightblue-v3" if month == Date.today.month
	end
end
