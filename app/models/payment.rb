class Payment < ActiveRecord::Base
  has_many :payment_components
  belongs_to :user

  def value
    @value
  end

  def value=(value)
    @value = value.to_f
  end

  def users
    @users
  end

  def users=(users)
    @users = users
    vals = @value / @users.length

    @users.each do |user|
      us = User.find(user)
      paid = (us == self.user)
      puts self.user
      pcs = PaymentComponent.create(:value => vals,
                                    :paid => paid,
                                    :user => us)
      self.payment_components << pcs
    end
  end

  def paid?
    self.payment_components.each do |pc|
      return false if !pc.paid?
    end
    return true
  end

  def self.all_paid
    result = []

    Payment.find(:all).each do |payment|
      result << payment if payment.paid?
    end

    result
  end

  def self.all_to_be_paid
    result = []
    
    Payment.find(:all).each do |payment|
      result << payment if !payment.paid?
    end

    result
  end
end
