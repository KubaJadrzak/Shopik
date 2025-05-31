require 'rails_helper'

RSpec.describe 'Espago Secure Web Page Payment Test', type: :system do
  let(:user) { create(:user) }
  let(:cart) { user.cart }
  let!(:product_in_cart) { create(:product, title: 'This is Product in Cart', price: 15) }
  let!(:other_product_in_cart) { create(:product, title: 'This is other Product in Cart', price: 20) }
  let!(:cart_item) { create(:cart_item, cart: cart, product: product_in_cart) }
  let!(:other_cart_item) { create(:cart_item, cart: cart, product: other_product_in_cart, quantity: 3) }


  before do
    sign_in user
    driven_by(:selenium_chrome_headless)
  end

  context 'when payment is successfull' do
    it 'user is redirected to order show page and shown success message' do
      visit cart_path
      expect(page).to have_content('Your Cart')
      expect(page).to have_content('This is Product in Cart')
      expect(page).to have_content('This is other Product in Cart')
      expect(page).to have_content('$75.00')
      click_link 'Place Order'
      expect(page).to have_content('Email')
      expect(page).to have_content('Shipping Address')

      fill_in 'Shipping Address', with: 'Shipping Address'

      click_button 'Purchase'
      expect(page).to have_current_path(/secure_web_page/, wait: 3)
      order = Order.last
      expect(page).to have_content(order.total_price)
      expect(page).to have_content(order.payment_id)
      expect(page).to have_content(order.order_number)

      # mock redirect to success to avoid going through external service
      visit "/espago/secure_web_page/payments/success?order_number=#{order.order_number}"
      expect(page).to have_content('Payment successful!')
      expect(page).to have_content(order.status)
      expect(page).to have_content(order.payment_status.capitalize)
    end
  end

  context 'when payment failed' do
    it 'user is redirected to order show page and shown fail message' do
      visit cart_path
      expect(page).to have_content('Your Cart')
      expect(page).to have_content('This is Product in Cart')
      expect(page).to have_content('This is other Product in Cart')
      expect(page).to have_content('$75.00')
      click_link 'Place Order'
      expect(page).to have_content('Email')
      expect(page).to have_content('Shipping Address')

      fill_in 'Shipping Address', with: 'Shipping Address'

      click_button 'Purchase'
      expect(page).to have_current_path(/secure_web_page/, wait: 3)
      order = Order.last
      expect(page).to have_content(order.total_price)
      expect(page).to have_content(order.payment_id)
      expect(page).to have_content(order.order_number)

      # mock redirect to failure to avoid going through external service
      visit "/espago/secure_web_page/payments/failure?order_number=#{order.order_number}"
      expect(page).to have_content('Payment failed!')
      expect(page).to have_content(order.status)
      expect(page).to have_content(order.payment_status.capitalize)
    end
  end
end
