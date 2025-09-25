# frozen_string_literal: true

FactoryBot.define do
  factory :product do
    title { 'Example Product' }
    description { 'This is an example product.' }
    price { 25.00 }
  end
end
