FactoryGirl.define do
  factory :receipt do
      check_amount 0
      deposit_date Date.today
      receipt_type 'combined'

  end
end
