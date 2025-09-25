# frozen_string_literal: true

FactoryBot.define do
  factory :user_with_cart_items, parent: :user do
    after(:create) do |user|
      cart = user.cart
      p1 = create(:product, title: 'This is Product in Cart', price: 15)
      p2 = create(:product, title: 'This is other Product in Cart', price: 20)
      create(:cart_item, cart: cart, product: p1)
      create(:cart_item, cart: cart, product: p2, quantity: 3)
    end
  end
end
