# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    association :user
    email { 'user1@example.com' }
    shipping_address { 'Poland, Main Street 123, 00-000' }
    status { 'New' }
    uuid { 'uuid' }
    ordered_at { Time.current }
    total_price { 30 }

    after(:build) do |order|
      product1 = create(:product, price: 15)
      product2 = create(:product, price: 25)

      order.order_items << build(:order_item, order: order, product: product1, quantity: 1, price_at_purchase: 15)
      order.order_items << build(:order_item, order: order, product: product2, quantity: 1, price_at_purchase: 25)
    end
  end
end
