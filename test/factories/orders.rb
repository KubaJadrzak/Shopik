FactoryBot.define do
  factory :order do
    association :user
    state { 'New' }
    email { user.email }
    shipping_address { 'Example Address' }
    total_price { 10.00 }
    ordered_at { Time.current }

    after(:build) do |order|
      order.order_items << build(:order_item, order: order)
    end
  end
end
