require 'rails_helper'

RSpec.describe 'Cart CartItem System Test', type: :system do
  let(:user) { create(:user) }
  let(:cart) { user.cart }
  let!(:product) { create(:product, title: 'This is Product') }
  let!(:product_in_cart) { create(:product, title: 'This is Product in Cart', price: 15) }
  let!(:other_product_in_cart) { create(:product, title: 'This is other Product in Cart', price: 20) }
  let!(:cart_item) { create(:cart_item, cart: cart, product: product_in_cart) }
  let!(:other_cart_item) { create(:cart_item, cart: cart, product: other_product_in_cart, quantity: 3) }


  context 'when user is signed in' do
    before do
      sign_in user
    end

    it 'user can visit cart show page' do
      visit root_path
      find('img[alt="Cart"]').click
      expect(page).to have_content('Your Cart')
      expect(page).to have_content('This is Product in Cart')
      expect(page).to have_content('This is other Product in Cart')
      expect(page).to have_content('$75.00')
    end

    it 'user can add product to cart' do
      visit products_path
      expect(page).to have_content('Add to Cart')
      within all('[data-testid="product"]').first do
        click_button('Add to Cart')
      end
      expect(page).to have_content('added to cart!')
      find('img[alt="Cart"]').click

      expect(page).to have_content('Your Cart')
      expect(page).to have_content('This is Product')
    end

    it 'user can remove product from cart' do
      visit cart_path
      within('tr#cart_item_1') do
        find('form.button_to .bi-trash').click
      end
      expect(page).to_not have_content('This is Product in Cart')
      expect(page).to have_content('$60.00')
    end
  end

  context 'when user is not signed in' do
    it 'user is redirected to sign in page when adding product to cart' do
      visit products_path
      expect(page).to have_content('Add to Cart')
      within all('[data-testid="product"]').first do
        click_button('Add to Cart')
      end
      expect(page).to have_content('Sign In')
    end

    it 'user is redirected to sign in page when visiting cart show page' do
      visit root_path
      find('img[alt="Cart"]').click
      expect(page).to have_content('Sign In')
      expect(page).to have_content('You need to sign in or sign up before continuing.')
    end
  end
end
