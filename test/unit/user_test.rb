require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "invalid with empty attributes" do
    user = User.new
    
    assert !user.valid?
    assert user.errors.invalid?(:name)
  end

  test "repeated usernames" do
    user1 = User.new(:name => 'User1',
                     :username => 'user',
                     :password => 'password',
                     :password_confirmation => 'password')
    assert user1.valid?
    user1.save

    user2 = User.new(:name => 'User2',
                     :username => 'user',
                     :password => 'password',
                     :password_confirmation => 'password')
    assert !user2.valid?
    assert user2.errors.invalid?(:username)
  end

  test "password confirmation" do
    user = User.new(:name => 'User',
                    :username => 'user',
                    :password => 'password1',
                    :password_confirmation => 'password2')
    assert !user.valid?
    assert user.errors.invalid?(:password)
  end

  test "amount owed" do
    Payment.create(:name => 'payment1',
                   :value => 2000,
                   :user => users(:joao),
                   :users => [users(:joao), users(:pacheco)])

    assert_equal users(:pacheco).amount_owed_to(users(:joao)), 1000

    Payment.create(:name => 'payment2',
                   :value => 1000,
                   :user => users(:pacheco),
                   :users => [users(:joao), users(:pacheco)])

    assert_equal users(:pacheco).amount_owed_to(users(:joao)), 500
    assert_equal users(:joao).amount_owed_to(users(:pacheco)), 0

    Payment.create(:name => 'payment3',
                   :value => 400,
                   :user => users(:telmo),
                   :users => [users(:joao), users(:pacheco), users(:telmo),
                              users(:simao)])

    assert_equal users(:joao).amount_owed_to(users(:telmo)), 100
    assert_equal users(:pacheco).amount_owed_to(users(:telmo)), 100
    assert_equal users(:simao).amount_owed_to(users(:telmo)), 100
  end

  test "update amount" do
    Payment.create(:name => 'payment1',
                   :value => 2000,
                   :user => users(:joao),
                   :users => [users(:joao), users(:pacheco)])
    Payment.create(:name => 'payment2',
                   :value => 1000,
                   :user => users(:pacheco),
                   :users => [users(:joao), users(:pacheco)])
    Payment.create(:name => 'payment3',
                   :value => 400,
                   :user => users(:telmo),
                   :users => [users(:joao), users(:pacheco), users(:telmo),
                              users(:simao)])

    users(:pacheco).update_amount(users(:joao), 250)
    assert_equal users(:pacheco).amount_owed_to(users(:joao)), 250
    users(:pacheco).update_amount(users(:joao), 250)
    assert_equal users(:pacheco).amount_owed_to(users(:joao)), 0
    users(:joao).update_amount(users(:telmo), 100)
    users(:pacheco).update_amount(users(:telmo), 100)
    users(:simao).update_amount(users(:telmo), 100)

    assert_equal Payment.all_not_paid.length, 0
  end
end
