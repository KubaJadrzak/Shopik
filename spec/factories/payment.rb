FactoryBot.define do
  factory :payment do
    amount { 4.99 }
    state { 'new' }
    reject_reason { nil }
    issuer_response_code { nil }
    behaviour { nil }
    payment_number { SecureRandom.hex(8) }

    trait :for_subscription do
      association :subscription
      order { nil }
    end

    trait :for_order do
      association :order
      subscription { nil }
    end
  end
end
