require 'rails_helper'

RSpec.describe 'User System Test', type: :system do
  let(:user) { create(:user) }

  context 'when user is not signed in' do
    it 'redirects user do sign in page when visiting account view' do
      visit root_path
      find('img[alt="Account"]').click
      expect(page).to have_content('Sign In')
      expect(page).to have_content('You need to sign in or sign up before continuing.')
    end
  end

  context 'when user is signed in' do
    let!(:rubit) { create(:rubit, user: user, content: 'This is Rubit in account view') }
    let!(:other_user) { create(:user) }
    let!(:other_rubit) { create(:rubit, user: other_user, content: 'This is liked Rubit in account view') }
    let!(:like) { create(:like, rubit: other_rubit, user: user) }
    let!(:comment) { create(:rubit, user: user, parent_rubit: other_rubit, content: 'This is comment') }
    let!(:order) { create(:order, user: user, order_number: 'qwerty1234') }
    before do
      sign_in user
    end

    it 'user can visit account view' do
      visit root_path
      find('img[alt="Account"]').click
      expect(page).to have_content('Your Rubits')
    end

    it 'user can switch between sidebar Rubit/Likes/Comments/Orders views' do
      visit root_path
      find('img[alt="Account"]').click
      expect(page).to have_content('Your Rubits')
      click_button 'Likes'
      expect(page).to have_content('Your Likes')
      click_button 'Comments'
      expect(page).to have_content('Your Comments')
      click_button 'Orders'
      expect(page).to have_content('Your Orders')
      click_button 'Rubits'
      expect(page).to have_content('Your Rubits')
    end

    it 'user can see their rubits' do
      visit root_path
      find('img[alt="Account"]').click
      click_button 'Rubits'
      expect(page).to have_content(rubit.content)
    end

    it 'user can see their likes' do
      visit root_path
      find('img[alt="Account"]').click
      click_button 'Likes'
      expect(page).to have_content(other_rubit.content)
      expect(page).to have_content('1 Like')
    end

    it 'user can see their comments' do
      visit root_path
      find('img[alt="Account"]').click
      click_button 'Comments'
      expect(page).to have_content(other_rubit.content)
      expect(page).to have_content(comment.content)
    end

    it 'user can see their orders' do
      visit root_path
      find('img[alt="Account"]').click
      click_button 'Orders'
      expect(page).to have_content(order.order_number)
      expect(page).to have_content(order.total_price)
    end
  end
end
