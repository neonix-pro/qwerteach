require 'test_helper'

class PaymentTest < ActiveSupport::TestCase
  test "the truth" do
    assert_equal 1, Payment.count
  end
  test "no status" do
    payment = Payment.first.update(:status => nil)
    assert_not payment
  end
  test "no price" do
    payment = Payment.first.update(:price => nil)
    assert_not payment
  end
  test "no lesson_id" do
    payment = Payment.first.update(:lesson_id => nil)
    assert_not payment
  end
  test "no payment_type" do
    payment = Payment.first.update(:payment_type => nil)
    assert_not payment
  end
  test "wrong price" do
    payment = Payment.first.update(:price => -5)
    assert_not payment
  end
  test "all ok" do
    assert_difference "Payment.count" do
      Payment.create(:lesson_id => 1, :price => 15.0)
    end
  end
end
