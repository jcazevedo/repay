class Payment < ActiveRecord::Base
  has_many   :payment_components
  belongs_to :user

  attr_writer :users

  validates_presence_of     :name,
                            :user_id,
                            :value
  validates_numericality_of :value
  validate                  :length_of_users_should_be_at_least_1,
                            :value_must_be_at_least_a_cent,
                            :payment_component_values_are_valid

  after_create :create_payment_components,
               :update_related_components

  def users
    return @users if @users

    @users = []
    self.payment_components.each do |pc|
      @users << pc.user
    end

    return @users
  end
  
  def paid?
    return self.paid == self.value
  end

  def has_user_component?(user)
    !user_component(user).nil?
  end

  def user_component_paid?(user)
    if self.has_user_component?(user)
      return user_component(user).paid?
    end

    return false
  end

  def user_component_value(user)
    if self.has_user_component?(user)
      component = user_component(user)
      return component.value
    end

    return 0
  end

  def user_component_paid(user)
    if self.has_user_component?(user)
      component = user_component(user)
      return component.paid
    end

    return 0
  end

  def user_component_owed(user)
    return self.user_component_value(user) - self.user_component_paid(user)
  end

  def update_user_component_paid(user, value)
    Payment.transaction do
      set_user_component_paid(user, value)
      update_paid
    end
  end

  def add_to_user_component_paid(user, value)
    current = self.user_component_paid(user)
    update_user_component_paid(user, value + current)
  end

  def self.all_paid
    Payment.find(:all,
                 :conditions => "paid = value",
                 :order => "created_at DESC")
  end

  def self.all_not_paid
    Payment.find(:all,
                 :conditions => "paid != value",
                 :order => "created_at DESC")
  end

  private

  def length_of_users_should_be_at_least_1
    errors.add(:users, 'should be at least 1') if users.nil? ||
      users.length == 0
  end

  def value_must_be_at_least_a_cent
    errors.add(:value, 'should be at least 0.01') if value.nil? || value < 0.01
  end

  def payment_component_values_are_valid
    self.payment_components.each do |pc|
      errors.add('payment_components[' + pc.user_id.to_s + ']', 'should be between 0 and ' + pc.value.to_s) if pc.paid < 0 || pc.paid > pc.value
    end
  end

  def update_paid
    self.paid = 0.0
    
    self.payment_components.each do |pc|
      pc.reload # might be needed to avoid caching
      self.paid += pc.paid
    end
    
    self.save(false)
  end

  def user_component(user)
    self.payment_components.find_by_user_id(user.id)
  end

  def set_user_component_paid(user, val)
    if has_user_component?(user)
      component = user_component(user)
      component.paid = val
      component.save
    end
  end

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

  def create_payment_component(user, value, cpaid)
    pc = PaymentComponent.create(:value => value, :paid => cpaid, :user => user)
    self.payment_components << pc
  end

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
