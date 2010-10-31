class Payment < ActiveRecord::Base
  has_many :payment_components

  def users
    @users
  end

  def users=(users)
    vals = self.value / users.length

    users.each do |user|
      pcs = PaymentComponent.create(:value => vals,
                                    :paid => false,
                                    :user => user)
      self.payment_components << pcs
    end
  end

  def paid?
    self.payment_components.each do |pc|
      return false if !pc.paid?
    end
    return true
  end
end
