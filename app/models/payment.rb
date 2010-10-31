class Payment < ActiveRecord::Base
  has_many :payment_components

  def value
    @value
  end

  def value=(value)
    @value = value
  end

  def users
    @users
  end

  def users=(users)
    @users = users
    vals = @value / @users.length

    @users.each do |user|
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
