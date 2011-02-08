require 'test_helper'

class PaymentTest < ActiveSupport::TestCase
  test "create_payment_components" do
    payment = Payment.create(:name => 'payment',
                             :value => 2000,
                             :user => users(:joao),
                             :users => [users(:joao), users(:pacheco)])

    assert payment.has_user_component?(users(:joao))
    assert payment.has_user_component?(users(:pacheco))
    assert !payment.has_user_component?(users(:telmo))
    assert !payment.has_user_component?(users(:simao))
  end

  test "payment_component_values" do
    payment = Payment.create(:name => 'payment',
                             :value => 2000,
                             :user => users(:joao),
                             :users => [users(:joao), users(:pacheco)])

    assert_equal payment.user_component_value(users(:joao)), 1000
    assert_equal payment.user_component_value(users(:pacheco)), 1000
    assert_equal payment.user_component_paid(users(:joao)), 1000
    assert_equal payment.user_component_paid(users(:pacheco)), 0
  end

  test "payment_component_updates" do
    payment = Payment.create(:name => 'payment',
                             :value => 2000,
                             :user => users(:joao),
                             :users => [users(:joao), users(:pacheco)])

    assert !payment.paid?
    payment.update_user_component_paid(users(:pacheco), 500)
    assert !payment.paid?
    payment.update_user_component_paid(users(:pacheco), 1000)
    assert payment.paid?
  end

  test "update_related_components_simple" do
    all_users = [users(:joao), users(:pacheco), users(:telmo), users(:simao)]

    payment1 = Payment.create(:name => 'payment1',
                              :value => 2000,
                              :user => users(:joao),
                              :users => all_users)

    payment2 = Payment.create(:name => 'payment2',
                              :value => 2000,
                              :user => users(:pacheco),
                              :users => all_users)

    payment3 = Payment.create(:name => 'payment3',
                              :value => 2000,
                              :user => users(:telmo),
                              :users => all_users)

    payment4 = Payment.create(:name => 'payment4',
                              :value => 2000,
                              :user => users(:simao),
                              :users => all_users)

    [payment1, payment2, payment3, payment4].each do |payment|
      payment.reload
      assert payment.paid?
      all_users.each do |user|
        assert payment.is_user_component_paid?(user)
      end
    end
  end

  test "update_related_components_partial" do
    all_users = [users(:joao), users(:pacheco), users(:telmo), users(:simao)]

    payment1 = Payment.create(:name => 'payment1',
                              :value => 2000,
                              :user => users(:joao),
                              :users => all_users)

    payment2 = Payment.create(:name => 'payment2',
                              :value => 250,
                              :user => users(:pacheco),
                              :users => [users(:joao)])

    assert_equal payment1.user_component_paid(users(:pacheco)), 250
    assert_equal payment2.user_component_paid(users(:joao)), 250

    payment3 = Payment.create(:name => "payment3",
                              :value => 1000,
                              :user => users(:pacheco),
                              :users => all_users)

    assert_equal payment1.user_component_paid(users(:pacheco)), 500
    assert payment1.is_user_component_paid?(users(:pacheco))
    assert_equal payment3.user_component_paid(users(:joao)), 250
  end
end
