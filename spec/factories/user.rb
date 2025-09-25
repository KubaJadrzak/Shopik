# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password' }
    password_confirmation { 'password' }
    sequence(:username) { |n| "user#{n}" }


    after(:create, &:create_cart!)
  end
end
