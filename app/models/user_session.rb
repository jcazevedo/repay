# The SessionUser class encapsulates the logic of a user session in the system.
#
# It is composed of:
# * user
# * paid
# * not_paid
class UserSession
  attr_accessor :user,
                :paid,
                :not_paid

  def load_paid?
    return self.paid
  end

  def load_not_paid?
    return self.not_paid
  end
end
