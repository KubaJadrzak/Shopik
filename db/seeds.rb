# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


User.destroy_all
Product.destroy_all
Cart.destroy_all
CartItem.destroy_all
Order.destroy_all
OrderItem.destroy_all
Subscription.destroy_all
Payment.destroy_all


user = []

3.times do |i|
  new_user = User.create!(
    email:                 "user#{i + 1}@example.com",
    password:              'password',
    password_confirmation: 'password',
    username:              "user#{i + 1}",
  )
  new_user.create_cart!
  user << new_user
end

Product.create!(
  title:            'shopik T-shirt',
  description:      'A comfy and stylish t-shirt featuring the iconic shopik logo. Perfect for showing off your shopik pride wherever you go.',
  price:            29.99,
  membership_price: 23.99,
)

Product.create!(
  title:            'shopik Mug',
  description:      'Start your day right with a shopik-themed mug. Ideal for sipping coffee or tea while coding.',
  price:            12.50,
  membership_price: 9.99,
)

Product.create!(
  title:            'shopik Hoodie',
  description:      'Stay warm and cozy with the shopik hoodie. A must-have for shopik enthusiasts during those late-night coding sessions.',
  price:            39.99,
  membership_price: 31.99,
)

Product.create!(
  title:            'shopik Hat',
  description:      'This stylish shopik beanie will keep your head warm while showing your love for shopik programming.',
  price:            15.00,
  membership_price: 11.99,
)

Product.create!(
  title:            'shopik Stickers',
  description:      'Decorate your laptop, water bottle, or anywhere with these high-quality shopik-themed stickers. Perfect for any shopik fan.',
  price:            3.99,
  membership_price: 3.19,
)

Product.create!(
  title:            'shopik Keychain',
  description:      'A durable shopik-themed keychain that makes it easy to carry your love for shopik everywhere you go.',
  price:            7.49,
  membership_price: 5.99,
)

Product.create!(
  title:            'shopik Socks',
  description:      'Comfortable and warm shopik socks to keep your feet cozy while you work on your next shopik project.',
  price:            9.99,
  membership_price: 7.99,
)

Product.create!(
  title:            'shopik Poster',
  description:      "Bring shopik to your walls with this sleek, modern poster. Ideal for any shopik developer's office or home.",
  price:            14.00,
  membership_price: 11.19,
)

Product.create!(
  title:            'shopik Tote Bag',
  description:      'Show off your shopik spirit with this eco-friendly, spacious tote bag. Perfect for carrying your laptop and other essentials.',
  price:            19.99,
  membership_price: 15.99,
)

Product.create!(
  title:            'shopik Phone Case',
  description:      'Protect your phone with a shopik-inspired case, designed to fit most modern smartphones while showing off your love for the language.',
  price:            16.49,
  membership_price: 13.19,
)
