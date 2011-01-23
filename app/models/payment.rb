class Payment < ActiveRecord::Base
  has_many :payment_components
  belongs_to :user

  attr_accessor :users, :value

  validates_presence_of :name, :user_id
  validate :validate_length_of_users, 
           :validate_numericality_of_value

  after_create :create_payment_components, :update_related_components

  def value
    @value.to_f
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
      if (payment.paid? and paid) or
          (!payment.paid? and not_paid)
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
    errors.add(:users, 'should be at least one') if users.nil? ||
      users.length == 0
  end

  def validate_numericality_of_value
    errors.add(:value, 'should be a number greater than or equal to 0.01') if 
      value < 0.01
  end

  def create_payment_components
    vals = value / users.length

    users.each do |user|
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

  def update_related_components
    payments = Payment.get_all(false, true).reverse!
    users = User.find(:all)
    users.each do |user|
      if user != self.user && !self.user_component(user).nil?
        val = self.user_component(user).value - self.user_component(user).paid
        payments = user.payments
        payments.each do |payment|
          if payment.user != self.user && 
              !payment.user_component(self.user).nil? && 

            pc = payment.user_component(self.user)
            this_pc = self.user_component(payment.user)
            if !pc.paid?
              pc.paid += val
              this_pc.paid += val
              val = 0
              
              if pc.paid >= pc.value
                val += (pc.paid - pc.value)
                this_pc.paid -= (pc.paid - pc.value)
                pc.paid = pc.value
              end

              pc.save
              this_pc.save
            end
          end
        end
      end
    end
  end
end
