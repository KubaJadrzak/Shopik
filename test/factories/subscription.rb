FactoryBot.define do
  factory :subscription do
    association :user
    start_date { Time.current }
    end_date { Time.current + 1.month }
    state { 'New' }
    created_at { Time.current }
    price { 4.99 }
  end
end
