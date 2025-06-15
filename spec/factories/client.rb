FactoryBot.define do
  factory :client do
    association :user
    sequence(:client_id) { |n| "client#{n}" }
    company { 'Example Company' }
    last4 { '1234' }
    first_name { 'John' }
    last_name { 'Doe' }
    status { 'CIT' }
    month { 1 }
    year { 2025 }
  end
end
