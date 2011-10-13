class PaymentComponent < ActiveRecord::Base
  belongs_to :payment
  belongs_to :user

  validates_presence_of :paid, :value, :user_id
  validates_numericality_of :paid, :value
  validate :paid_is_between_0_and_value

  def paid?
    (paid*100).to_i >= (value*100).to_i
  end

  private

  def paid_is_between_0_and_value
    if self.paid < 0 || self.paid > self.value
      errors.add(:paid, 'must be between 0 and ' + self.value.to_s)
    end
  end
end
