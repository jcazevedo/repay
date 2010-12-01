class Credit < ActiveRecord::Base
  belongs_to :user
  belongs_to :other_user, :class_name => 'User'

  validates_presence_of :user, :other_user, :value
  validates_numericality_of :value
end
