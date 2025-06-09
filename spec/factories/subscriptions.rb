FactoryBot.define do
  factory :subscription do
    association :user
    start_date { Date.today }
    end_date { 1.month.from_now.to_date }
    status { 'New' }
    auto_renew { true }
    price { 9.99 }
    sequence(:subscription_number) { SecureRandom.hex(8) }
  end
end
