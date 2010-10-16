class Payment < ActiveRecord::Base
  has_many :payment_components

  def paid?
    self.payment_components.each do |pc|
      return false if !pc.paid?
    end
    return true
  end
end
