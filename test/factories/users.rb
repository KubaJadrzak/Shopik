# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "jan.kowalski#{n}@example.com" }
    sequence(:username) { |n| "example#{n}" }
    password { 'example123' }
    password_confirmation { 'example123' }
    auto_renew { false }

    after(:create) do |user|
      create(:cart, user: user)
    end
  end

  trait :with_auto_renew do
    auto_renew { true }
  end

  trait :with_order do
    after(:create) do |user|
      create(:order, user: user)
    end
  end

  trait :with_saved_payment_method do
    after(:create) do |user|
      create(:saved_payment_method, user: user)
    end
  end
end
