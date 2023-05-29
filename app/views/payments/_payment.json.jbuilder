json.extract! payment, :id, :sale_id, :date, :payment, :payments_currency_id, :total, :take_in, :active, :comment, :created_at, :updated_at
json.url payment_url(payment, format: :json)
