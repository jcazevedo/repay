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
end
