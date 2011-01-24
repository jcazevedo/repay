class Payment < ActiveRecord::Base
  has_many :payment_components
  belongs_to :user

  attr_accessor :users

  validates_presence_of :name, :user_id, :value
  validates_numericality_of :value
  validate :validate_length_of_users

  after_create :create_payment_components, :update_related_components

  def paid?
    paid == value
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

  def has_user_component?(user)
    !get_user_component(user).nil?
  end

  def is_user_component_paid?(user)
    if has_user_component?(user)
      component = get_user_component(user)
      return component.paid?
    end

    return false
  end

  def user_component_value(user)
    component = user_component(user)
    component.value
  end

  def update_user_component_value(user, value)
    set_user_component_value(user, value)
    self.update_paid
  end

  private

  def validate_length_of_users
    errors.add(:users, 'should be at least one') if users.nil? ||
      users.length == 0
  end

  def update_paid
    self.paid = 0.0
    
    self.payment_components.each do |payment|
      self.paid += self.payment_components.paid
    end

    self.save
  end

  def user_component(user)
    self.payment_components.find_by_user_id(user.id)
  end

  def set_user_component_value(user, value)
    if has_user_component?(user)
      component = user_component(user)
      component.value = value
      component.save
    end
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

      create_payment_component(vals, paid, us)
    end
  end

  def create_payment_component(value, paid, user)
    pc = PaymentComponent.create(:value => value, :paid => paid, :user => user)
    self.payment_components << pc
  end

  def update_related_components
    payments = Payment.get_all(false, true).reverse!
    users = User.find(:all)
    users.each do |user|
      if user != self.user && !self.user_component(user).nil?
        val = self.user_component_value(user) - self.user_component_value(user)
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
