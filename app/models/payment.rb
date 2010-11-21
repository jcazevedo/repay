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

  def add_amount(user, value)
    pc = self.payment_components.find_by_user_id(user)
    if pc
      pc.paid += value
      # TODO instead of checking the following, it would probably be a better
      # idea to accumulate amounts given by other users.
      pc.paid = pc.value if pc.paid >= pc.value
      pc.save
    end
  end

  def users=(users)
    @users = users
    vals = @value / @users.length

    @users.each do |user|
      us = User.find(user)
      if us == self.user
        paid = vals
      else
        paid = 0
      end
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

  def user_component(user)
    self.payment_components.find_by_user_id(user.id)
  end
end
