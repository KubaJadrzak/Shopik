FactoryBot.define do
  factory :rubit do
    sequence(:content) { |n| "This is an example Rubit number #{n}" }
    association :user

    parent_rubit { nil }

    trait :child do
      association :parent_rubit, factory: :rubit
    end
  end
end
