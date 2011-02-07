# The Credit class encapsulates the logic of a credit a User has toward another
# one. It is still in experimental state.
class Credit < ActiveRecord::Base
  belongs_to :user
  belongs_to :other_user, :class_name => 'User'

  validates_presence_of :user, :other_user, :value
  validates_numericality_of :value
end
