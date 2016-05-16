FactoryGirl.define do
  factory :lien do
    #These have to be listed first?
    transient do
      receipt_count 0
      subsequent_count 0
    end

    #This has to be listed right after transient???
    after(:create) do |lien, evaluator|
      create_list(:receipt, evaluator.receipt_count, lien: lien)
      create_list(:subsequent, evaluator.subsequent_count, lien: lien)
    end

    trait :has_sub do
      subsequent_count 1
    end

    trait :has_receipt do
      receipt_count 1
    end

    county "Atlantic City"
    search_fee 1200
    yep_interest nil
    cert_number "14-00025"

    premium 1000000
    recording_fee 4000
    flat_rate 142962
    cert_int 0
    redemption_amount 3628069
    cert_fv 2382715

    association :township, factory: :township
  end
end
