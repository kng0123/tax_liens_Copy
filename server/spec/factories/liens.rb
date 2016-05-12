FactoryGirl.define do
  factory :lien do
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
