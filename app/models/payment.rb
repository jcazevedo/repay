# The Payment class encapsulates the logic of a payment in the system.
# 
# It is composed of:
# * name
# * description
# * name
# * value
# * paid
class Payment < ActiveRecord::Base
  has_many :payment_components
  belongs_to :user

  attr_accessor :users

  validates_presence_of :name, :user_id, :value
  validates_numericality_of :value
  validate :validate_length_of_users

  after_create :create_payment_components, :update_related_components
  
  # Checks if all PaymentComponent are paid.
  def paid?
    paid == value
  end

  # Returns a boolean stating whether or not the User given as parameter has a
  # PaymentComponent in the Payment.
  def has_user_component?(user)
    !user_component(user).nil?
  end

  # Returns a boolean stating whether or not the PaymentComponent for the User
  # given as parameter is paid.
  def is_user_component_paid?(user)
    if has_user_component?(user)
      component = user_component(user)
      return component.paid?
    end

    return false
  end

  # Returns the value of the PaymentComponent for the User given as parameter
  def user_component_value(user)
    if has_user_component?(user)
      component = user_component(user)
      return component.value
    end

    return 0
  end

  # Updates the PaymentComponent for the User given as parameter with the given
  # value.
  def update_user_component_value(user, value)
    set_user_component_value(user, value)
    self.update_paid
  end

  # TODO refactor
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

  private

  # Validates if the users list is of length above 0.
  def validate_length_of_users
    errors.add(:users, 'should be at least one') if users.nil? ||
      users.length == 0
  end

  # Updates the value of the paid attribute for the Payment, based on the paid
  # values of PaymentComponent.
  def update_paid
    self.paid = 0.0
    
    self.payment_components.each do |payment|
      self.paid += self.payment_components.paid
    end

    self.save
  end

  # Returns the PaymentComponent for the User given as parameter.
  def user_component(user)
    self.payment_components.find_by_user_id(user.id)
  end

  # Sets the value of the PaymentComponent associated with the User given as
  # parameter.
  def set_user_component_value(user, value)
    if has_user_component?(user)
      component = user_component(user)
      component.value = value
      component.save
    end
  end

  # Creates PaymentComponent based on the value of the Payment and the list of
  # Users associated with it.
  def create_payment_components
    vals = self.value / users.length

    users.each do |user|
      us = User.find(user)
      if us == self.user
        paid = vals
      else
        paid = 0
      end

      create_payment_component(us, vals, paid)
    end
  end

  # Creates a single PaymentComponent, for the User given as parameter, with the
  # given value and paid status.
  def create_payment_component(user, value, paid)
    pc = PaymentComponent.create(:value => value, :paid => paid, :user => user)
    self.payment_components << pc
  end

  # Updates the list of PaymentComponent associated with a Payment after the
  # creation of a Payment.
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
