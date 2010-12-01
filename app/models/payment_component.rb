class PaymentComponent < ActiveRecord::Base
  belongs_to :payment
  belongs_to :user

  validates_presence_of :paid, :value, :user_id
  validates_numericality_of :paid, :value

  def paid?
    paid >= value
  end
end
