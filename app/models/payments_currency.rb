class PaymentsCurrency < ApplicationRecord
  belongs_to :payment_type
  belongs_to :currency
end
