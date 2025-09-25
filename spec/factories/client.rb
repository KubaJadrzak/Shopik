# frozen_string_literal: true

FactoryBot.define do
  factory :client do
    association :user
    sequence(:client_id) { |n| "client#{n}" }
    primary { false }
    company { 'Example Company' }
    last4 { '1234' }
    first_name { 'John' }
    last_name { 'Doe' }
    status { 'CIT' }
    month { 1 }
    year { 2025 }

    trait :primary do
      primary { true }
      status { 'MIT' }
    end

    trait :real do
      client_id { 'cli_9cbbpQpSUgQo4BGp' }
    end
  end
end
