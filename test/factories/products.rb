FactoryBot.define do
  factory :product do
    sequence(:title) { |n| "Example#{n}" }
    description { 'Example Description' }
    price { 10.00 }
    membership_price { 9.00 }
  end
end
