require 'rails_helper'

RSpec.describe 'Products System Test', type: :system do
  let(:user) { create(:user) }
  let!(:product) { create(:product, title: 'Test Product 1') }
  let!(:cart) { user.cart }

  it 'user can visit products index page' do
    visit root_path
    find('img[alt="Product"]').click
    expect(page).to have_content('Test Product 1')

  end
end
