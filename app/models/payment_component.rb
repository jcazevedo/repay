class PaymentComponent < ActiveRecord::Base
  belongs_to :payment
  belongs_to :user
end
