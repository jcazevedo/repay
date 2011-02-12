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
  validate :validate_length_of_users, :value_must_be_at_least_a_cent

  after_create :create_payment_components, :update_related_components
  
  # Checks if all PaymentComponent are paid.
  def paid?
    return self.paid == self.value
  end

  # Returns a boolean stating whether or not the User given as parameter has a
  # PaymentComponent in the Payment.
  def has_user_component?(user)
    !user_component(user).nil?
  end

  # Returns a boolean stating whether or not the PaymentComponent for the User
  # given as parameter is paid.
  def user_component_paid?(user)
    if self.has_user_component?(user)
      return user_component(user).paid?
    end

    return false
  end

  # Returns the value of the PaymentComponent for the User given as parameter.
  def user_component_value(user)
    if self.has_user_component?(user)
      component = user_component(user)
      return component.value
    end

    return 0
  end

  # Returns the paid amount of the PaymentComponent for the User given as
  # parameter.
  def user_component_paid(user)
    if self.has_user_component?(user)
      component = user_component(user)
      return component.paid
    end

    return 0
  end

  # Returns the amount owed by the User given as parameter to the owner of the
  # Payment.
  def user_component_owed(user)
    return self.user_component_value(user) - self.user_component_paid(user)
  end

  # Updates the PaymentComponent for the User given as parameter with the given
  # value.
  def update_user_component_paid(user, value)
    Payment.transaction do
      set_user_component_paid(user, value)
      update_paid
    end
  end

  # Adds the value given as parameter to the paid value of the PaymentComponent
  # of the User.
  def add_to_user_component_paid(user, value)
    current = self.user_component_paid(user)
    update_user_component_paid(user, value + current)
  end

  # Returns all Payment objects that are paid.
  def self.all_paid
    Payment.find(:all,
                 :conditions => "paid == value",
                 :order => "created_at DESC")
  end

  # Returns all Payment objects that are not paid.
  def self.all_not_paid
    Payment.find(:all,
                 :conditions => "paid != value",
                 :order => "created_at DESC")
  end

  private

  # Validates if the users list is of length above 0.
  def validate_length_of_users
    errors.add(:users, 'should be at least one') if users.nil? ||
      users.length == 0
  end

  # Creates an error in case the value field is below 0.01.
  def value_must_be_at_least_a_cent
    errors.add(:value, 'should be at least 0.01') if value.nil? || value < 0.01
  end

  # Updates the value of the paid attribute for the Payment, based on the paid
  # values of PaymentComponent.
  def update_paid
    self.paid = 0.0
    
    self.payment_components.each do |pc|
      pc.reload # might be needed to avoid caching
      self.paid += pc.paid
    end
    
    self.save(false)
  end

  # Returns the PaymentComponent for the User given as parameter.
  def user_component(user)
    self.payment_components.find_by_user_id(user.id)
  end

  # Sets the value of the PaymentComponent associated with the User given as
  # parameter.
  def set_user_component_paid(user, val)
    if has_user_component?(user)
      component = user_component(user)
      component.paid = val
      component.save
    end
  end

  # Creates PaymentComponent based on the value of the Payment and the list of
  # Users associated with it.
  def create_payment_components
    vals = self.value / self.users.length
    cpaid = 0

    users.each do |user|
      us = User.find(user)
      if us == self.user
        cpaid = vals
      else
        cpaid = 0
      end

      create_payment_component(us, vals, cpaid)
    end

    update_paid
  end

  # Creates a single PaymentComponent, for the User given as parameter, with the
  # given value and paid status.
  def create_payment_component(user, value, cpaid)
    pc = PaymentComponent.create(:value => value, :paid => cpaid, :user => user)
    self.payment_components << pc
  end

  # Updates the list of PaymentComponent associated with a Payment after the
  # creation of a Payment.
  def update_related_components
    payments = Payment.all_not_paid.reverse!
    users = User.find(:all)
    users.each do |user|
      if user != self.user && self.has_user_component?(user)
        val = self.user_component_value(user) - self.user_component_paid(user)
        payments = user.payments
        payments.each do |payment|
          if payment.user != self.user && payment.has_user_component?(self.user)
            pc_paid = payment.user_component_paid(self.user)
            pc_value = payment.user_component_value(self.user)
            this_pc_paid = self.user_component_paid(payment.user)

            if !payment.user_component_paid?(self.user)
              pc_paid += val
              this_pc_paid += val
              val = 0
              
              if pc_paid >= pc_value
                val += (pc_paid - pc_value)
                this_pc_paid -= pc_paid - pc_value
                pc_paid = pc_value
              end

              payment.update_user_component_paid(self.user, pc_paid)
              self.update_user_component_paid(payment.user, this_pc_paid)
            end
          end
        end
      end
    end
  end
end
