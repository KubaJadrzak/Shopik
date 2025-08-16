FactoryBot.define do
  factory :payment do
    amount { 4.99 }
    state { 'new' }
    reject_reason { nil }
    issuer_response_code { nil }
    behaviour { nil }
    payment_number { SecureRandom.hex(8) }

    association :payable, factory: :order

    trait :for_subscription do
      association :payable, factory: :subscription
    end

    trait :for_order do
      association :payable, factory: :order
    end

    trait :for_client do
      association :payable, factory: :client
    end

    trait :executed do
      state { 'executed' }
    end

    trait :finalized do
      state { 'finalized' }
    end


    trait :to_be_finalized do
      state { 'executed' }
      updated_at { 2.hours.ago }
    end
  end
end
