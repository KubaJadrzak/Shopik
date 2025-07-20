FactoryBot.define do
  factory :subscription do
    association :user
    start_date { Date.today }
    end_date { 30.days.from_now.to_date }
    status { 'Active' }
    auto_renew { false }
    price { 4.99 }
    sequence(:subscription_number) { SecureRandom.hex(8) }

    trait :new do
      start_date { nil }
      end_date { nil }
      status { 'New' }
    end
  end
end
