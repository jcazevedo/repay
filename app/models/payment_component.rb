# The PaymentComponent class encapsulates the logic of a component associated
# with a Payment in a system. A PaymentComponent represents a quota of a Payment
# associated with a User.
#
# It is composed of:
# * payment
# * user
# * value
# * paid
class PaymentComponent < ActiveRecord::Base
  belongs_to :payment
  belongs_to :user

  validates_presence_of :paid, :value, :user_id
  validates_numericality_of :paid, :value
  validate :paid_is_between_0_and_value

  # Returns a boolean stating whether or not the PaymentComponent is fully paid.
  def paid?
    paid >= value
  end

  private

  def paid_is_between_0_and_value
    if self.paid < 0 || self.paid > self.value
      errors.add(:paid, 'must be between 0 and ' + self.value.to_s)
    end
  end
end
