FactoryBot.define do
  factory :product do
    title { 'Example Product' }
    description { 'Example Description' }
    price { 10.00 }
    membership_price { 9.00 }
  end
end
