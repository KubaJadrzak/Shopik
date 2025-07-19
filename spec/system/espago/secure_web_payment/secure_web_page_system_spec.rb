require 'rails_helper'

RSpec.describe 'Secure Web Page Test', type: :system do
  let(:user) { create(:user) }
  let(:cart) { user.cart }
  let!(:product_in_cart) { create(:product, title: 'This is Product in Cart', price: 15) }
  let!(:other_product_in_cart) { create(:product, title: 'This is other Product in Cart', price: 20) }
  let!(:cart_item) { create(:cart_item, cart: cart, product: product_in_cart) }
  let!(:other_cart_item) { create(:cart_item, cart: cart, product: other_product_in_cart, quantity: 3) }


  before do
    sign_in user
  end

  context 'when payment is successfull' do
    it 'user is redirected to Secure Web Page, process through Secure Web Page and is redirected to order show page and shown success message' do
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

      choose('Secure Web Page')

      find('#pay_btn').click

      expect(page).to have_current_path(/secure_web_page/, wait: 3)
      order = Order.last
      payment = Payment.last
      expect(page).to have_content(order.total_price)
      expect(page).to have_content(payment.payment_number)
      expect(page).to have_content(payment.payment_id)


      expect(page).to have_content('Payment successful!')
      expect(page).to have_content(order.order_number)
      expect(page).to have_content(payment.payment_number)
    end
  end

  context 'when payment failed' do
    it 'user is redirected to Secure Web Page, process through Secure Web Page and is redirected to order show page and shown fail message' do
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

      choose('Secure Web Page')

      find('#pay_btn').click

      expect(page).to have_current_path(/secure_web_page/, wait: 3)
      order = Order.last
      payment = Payment.last
      expect(page).to have_content(order.total_price)
      expect(page).to have_content(payment.payment_number)
      expect(page).to have_content(payment.payment_id)

      # mock redirect to failure to avoid going through external service
      visit "/espago/payments/#{payment.payment_number}/failure"
      expect(page).to have_content('Payment failed!')
      expect(page).to have_content(order.status)
      expect(page).to have_content(payment.payment_number)
    end
  end
end
