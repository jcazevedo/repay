require 'digest/sha1'

# The User class encapsulates the logic of a user in the system.
# 
# It is composed of:
# * name
# * username
# * hashed_password
# * salt
class User < ActiveRecord::Base
  has_many :payments
  has_many :payment_components

  cattr_accessor :current_session
  attr_accessor  :password_confirmation
  attr_reader    :password

  validates_presence_of     :name,
                            :username
  validates_uniqueness_of   :username
  validates_confirmation_of :password
  validate                  :password_non_blank

  # Sets the user password.
  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = User.encrypted_password(self.password, self.salt)
  end

  def admin?
    return self.admin
  end

  # Returns the user with the given username and matching the given password.
  def self.authenticate(username, password)
    user = self.find_by_username(username)
    if user
      expected_password = encrypted_password(password, user.salt)
      if user.hashed_password != expected_password
        user = nil
      end
    end
    user
  end

  # Updates all amounts owed to user with the given value.
  def update_amount(user, value)
    Payment.all_not_paid.each do |payment|
      break if value <= 0
      if payment.user == user
        to_pay = payment.user_component_owed(self)
        to_pay = value if value < to_pay
        payment.add_to_user_component_paid(self, to_pay)

        value -= to_pay
      end
    end
  end

  # Returns the amount owed to the User given as parameter.
  def amount_owed_to(user)
    sum = 0.0

    Payment.all_not_paid.each do |payment|
      if payment.user == user
        sum += payment.user_component_owed(self)
      end
    end

    return sum
  end

  private

  # Validates that the supplied password isn't blank.
  def password_non_blank
    errors.add(:password, "Missing password") if hashed_password.blank?
  end

  # Returns the given password encrypted with the given salt.
  def self.encrypted_password(password, salt)
    string_to_hash = password + "wibble" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end

  # Creates a new randomized salt for the current User.
  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end
end
