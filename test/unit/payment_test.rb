require 'test_helper'

class PaymentTest < ActiveSupport::TestCase
  test "invalid with empty attributes" do
    payment = Payment.new
    assert !payment.valid?

    assert payment.errors.invalid?(:name)
    assert payment.errors.invalid?(:user_id)
    assert payment.errors.invalid?(:users)
  end

  test "positive value" do
    payment = Payment.new(:name => 'payment',
                          :user => users(:joao),
                          :value => -0.5)
    assert !payment.valid?
    assert payment.errors.invalid?(:value)
  end

  test "create payment components" do
    payment = Payment.create(:name => 'payment',
                             :value => 2000,
                             :user => users(:joao),
                             :users => [users(:joao), users(:pacheco)])

    assert payment.has_user_component?(users(:joao))
    assert payment.has_user_component?(users(:pacheco))
    assert !payment.has_user_component?(users(:telmo))
    assert !payment.has_user_component?(users(:simao))
  end

  test "payment component values" do
    payment = Payment.create(:name => 'payment',
                             :value => 2000,
                             :user => users(:joao),
                             :users => [users(:joao), users(:pacheco)])

    assert_equal payment.user_component_value(users(:joao)), 1000
    assert_equal payment.user_component_value(users(:pacheco)), 1000
    assert_equal payment.user_component_paid(users(:joao)), 1000
    assert_equal payment.user_component_paid(users(:pacheco)), 0
  end

  test "payment component updates" do
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

  test "update related components simple" do
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
        assert payment.user_component_paid?(user)
      end
    end
  end

  test "update related components partial" do
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
    assert payment1.user_component_paid?(users(:pacheco))
    assert_equal payment3.user_component_paid(users(:joao)), 250

    payment4 = Payment.create(:name => "payment4",
                              :value => 3000,
                              :user => users(:telmo),
                              :users => [users(:joao),
                                         users(:telmo),
                                         users(:simao)])

    assert_equal payment4.user_component_paid(users(:joao)), 500
    assert_equal payment1.user_component_paid(users(:telmo)), 500

    payment5 = Payment.create(:name => "payment5",
                              :value => 250,
                              :user => users(:joao),
                              :users => [users(:telmo)])

    assert_equal payment5.user_component_paid(users(:telmo)), 250
    assert_equal payment4.user_component_paid(users(:joao)), 750

    payment6 = Payment.create(:name => "payment6",
                              :value => 500,
                              :user => users(:simao),
                              :users => [users(:joao)])

    assert_equal payment1.user_component_paid(users(:simao)), 500
    assert_equal payment6.user_component_paid(users(:joao)), 500

    payment7 = Payment.create(:name => "payment7",
                              :value => 250,
                              :user => users(:simao),
                              :users => [users(:pacheco)])

    assert_equal payment3.user_component_paid(users(:simao)), 250
    assert_equal payment7.user_component_paid(users(:pacheco)), 250

    payment8 = Payment.create(:name => "payment8",
                              :value => 1000,
                              :user => users(:simao),
                              :users => [users(:telmo)])
    
    assert_equal payment4.user_component_paid(users(:simao)), 1000
    assert_equal payment8.user_component_paid(users(:telmo)), 1000

    payment9 = Payment.create(:name => "payment9",
                              :value => 250,
                              :user => users(:joao),
                              :users => [users(:telmo)])
    
    assert_equal payment9.user_component_paid(users(:telmo)), 250
    assert_equal payment4.user_component_paid(users(:joao)), 1000

    payment10 = Payment.create(:name => "payment10",
                               :value => 250,
                               :user => users(:telmo),
                               :users => [users(:pacheco)])

    assert_equal payment3.user_component_paid(users(:telmo)), 250
    assert_equal payment10.user_component_paid(users(:pacheco)), 250

    [payment1,
     payment2,
     payment3,
     payment4,
     payment5,
     payment6,
     payment7,
     payment8,
     payment9].each do |payment|
      payment.reload
      assert payment.paid?
    end
  end
end
