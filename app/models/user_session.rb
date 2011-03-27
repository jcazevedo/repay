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

  def locale
    return user.locale
  end
end
