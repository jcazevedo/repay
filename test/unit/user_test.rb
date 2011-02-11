require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "amount_owed" do
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

  test "update_amount" do
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
