# frozen_string_literal: true

# frozent_string_literal: true

FactoryBot.define do
  factory :cart do
    association :user

    trait :with_cart_item do
      after(:create) do |cart|
        create(:cart_item, cart: cart)
      end
    end
  end
end
