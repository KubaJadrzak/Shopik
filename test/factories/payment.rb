FactoryBot.define do
  factory :payment do
    association :payable
    amount { 10.00 }
    state { 'new' }
    payment_method { 'secure_web_page' }
    currency { 'PLN' }
    kind { 'sale' }
    created_at { Time.current }
    updated_at { Time.current }
  end

  trait :reversable do
    state { 'executed' }
    espago_payment_id { 'pay_9d0MB60taOJrWmqn' } # this is real espago_payment_id
  end

  trait :refundable do
    state { 'finalized' }
    espago_payment_id { 'pay_9d0qcbd9wGrf4WtM' } # this is real espago_payment_id
  end
end
