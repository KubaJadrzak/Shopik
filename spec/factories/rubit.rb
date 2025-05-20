FactoryBot.define do
  factory :rubit do
    sequence(:content) { |n| "This is an example Rubit number #{n}" }
    association :user
  end
end
