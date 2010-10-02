class Payment < ActiveRecord::Base
  has_many :payment_components
end
