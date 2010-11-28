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

  def self.get_all(paid, not_paid)
    @payments = Payment.find(:all, :order => 'created_at DESC')
    @payments.each do |payment|
      @payments.delete(payment) if ((payment.paid? and paid.nil?) or
                                    (!payment.paid? and not_paid.nil?))
    end
    @payments
  end

  def user_component(user)
    self.payment_components.find_by_user_id(user.id)
  end
end
