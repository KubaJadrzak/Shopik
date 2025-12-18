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
end
