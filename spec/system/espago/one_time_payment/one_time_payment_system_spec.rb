# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'One Time Payment Test', type: :system do
  let(:user) { create(:user) }
  let(:cart) { user.cart }
  let!(:product_in_cart) { create(:product, title: 'This is Product in Cart', price: 15) }
  let!(:other_product_in_cart) { create(:product, title: 'This is other Product in Cart', price: 20) }
  let!(:cart_item) { create(:cart_item, cart: cart, product: product_in_cart) }
  let!(:other_cart_item) { create(:cart_item, cart: cart, product: other_product_in_cart, quantity: 3) }


  before do
    sign_in user
  end

  describe 'when payment is successful' do

    it 'user is redirected to 3d secure page, confirms 3d secure, is redirected to order show view with success message' do
      visit cart_path
      expect(page).to have_content('Your Cart')
      expect(page).to have_content('This is Product in Cart')
      expect(page).to have_content('This is other Product in Cart')
      expect(page).to have_content('$75.00')
      click_link 'Place Order'
      expect(page).to have_content('Email')
      expect(page).to have_content('Shipping Address')

      fill_in 'Shipping Address', with: 'Shipping Address'

      click_button 'Go to Payment'

      expect(page).to have_content('Choose Payment Method')

      choose 'One-time Payment'

      find('#pay_btn').click

      within_frame(find('iframe')) do
        fill_in 'Imię', with: 'Jan'
        fill_in 'Nazwisko', with: 'Kowalski'
        fill_in 'Numer karty', with: '4012000000020006'
        fill_in 'MM', with: '1'
        fill_in 'RR', with: '30'
        fill_in 'CVV', with: '123'
        click_button 'Pay'
      end

      expect(page).to have_current_path(/secure_web_page/, wait: 10)

      within_frame(find('iframe')) do
        sleep 3
        expect(page).to have_content('3D-Secure 2 Payment - simulation')
        page.execute_script("document.querySelector('#confirm-btn').click()")
      end
      order = Order.last
      expect(page).to have_content(order.order_number, wait: 10)
      expect(page).to have_selector('#flash', text: 'Payment successful!')

    end

  end

  describe 'when payment failed' do
    it 'user is redirected to 3d secure page, confirms 3d secure, is redirected to order show view with failed message' do
      visit cart_path
      expect(page).to have_content('Your Cart')
      expect(page).to have_content('This is Product in Cart')
      expect(page).to have_content('This is other Product in Cart')
      expect(page).to have_content('$75.00')
      click_link 'Place Order'
      expect(page).to have_content('Email')
      expect(page).to have_content('Shipping Address')

      fill_in 'Shipping Address', with: 'Shipping Address'

      click_button 'Go to Payment'

      expect(page).to have_content('Choose Payment Method')

      choose 'One-time Payment'

      find('#pay_btn').click

      within_frame(find('iframe')) do
        fill_in 'Imię', with: 'Jan'
        fill_in 'Nazwisko', with: 'Kowalski'
        fill_in 'Numer karty', with: '4012000000020006'
        fill_in 'MM', with: '12'
        fill_in 'RR', with: '30'
        fill_in 'CVV', with: '123'
        click_button 'Pay'
      end

      expect(page).to have_current_path(/secure_web_page/, wait: 10)

      within_frame(find('iframe')) do
        sleep 3
        expect(page).to have_content('3D-Secure 2 Payment - simulation')
        page.execute_script("document.querySelector('#confirm-btn').click()")
      end

      order = Order.last
      expect(page).to have_content(order.order_number, wait: 10)
      expect(page).to have_content('Payment failed!', wait: 10)
    end
  end

end
