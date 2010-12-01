class Payment < ActiveRecord::Base
  has_many :payment_components
  belongs_to :user

  validates_presence_of :name, :user_id
  validate :validate_length_of_users,
           :validate_numericality_of_value

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

  def total
    sum = 0.0
    self.payment_components.each do |pc|
      sum += pc.value
    end
    sum
  end

  def self.get_all(paid, not_paid)
    payments = Payment.find(:all, :order => 'created_at DESC')
    payments_final = []
    payments.each do |payment|
      if (!payment.paid? or !paid.nil?) and (payment.paid? or !not_paid.nil?)
        payments_final << payment
      end
    end
    payments_final
  end

  def user_component(user)
    self.payment_components.find_by_user_id(user.id)
  end

  private

  def validate_length_of_users
    errors.add(:users, 'should be at least one') if @users.nil? ||
      @users.length == 0
  end

  def validate_numericality_of_value
    errors.add(:value, 'should be a number greater than or equal to 0.01') if 
      @value < 0.01
  end
end
