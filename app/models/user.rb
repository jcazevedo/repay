require 'digest/sha1'

# The User class encapsulates the logic of a user in the system.
# 
# It is composed of:
# * name
# * username
# * hashed_password
# * salt
class User < ActiveRecord::Base
  validates_presence_of   :name
  validates_uniqueness_of :name

  attr_accessor :password_confirmation
  validates_confirmation_of :password

  validate :password_non_blank

  has_many :payments
  has_many :payment_components

  # Returns the user password.
  def password
    @password
  end

  # Sets the user password.
  def password=(pwd)
    @password = pwd
    return if pwd.blank?
    create_new_salt
    self.hashed_password = User.encrypted_password(self.password, self.salt)
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

  # Updates all PaymentComponent for a user who has received the given value.
  def update_amount(user, value)
    self.payment_components.find(:all, :order => 'created_at ASC').each do |pc|
      if pc.payment.user == user && !pc.paid?
        pc.paid += value
        value = 0
        if pc.paid >= pc.value
          value += (pc.paid - pc.value)
          pc.paid = pc.value
        end
        pc.save
      end
    end
  end

  # Returns the amount owed to the User given as parameter.
  def amount_owed_to(user)
    sum = 0.0
    self.payment_components.each do |pc|
      if !pc.paid? && pc.payment.user == user
        sum += (pc.value - pc.paid)
      end
    end
    sum
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
