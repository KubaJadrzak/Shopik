require 'rails_helper'

RSpec.describe 'Likes System Test', type: :system do
  let!(:user) { create(:user) }
  let!(:rubit) { create(:rubit, content: 'This is Rubit', user: user) }
  context 'wher user is signed in' do
    before do
      sign_in user
    end
    it 'user can like Rubit' do
      visit root_path
      expect(page).to have_content('This is Rubit')
      expect(page).to have_content('0 Likes')
      expect(page).to have_selector('form.button_to .bi-heart')

      find('form.button_to .bi-heart').click
      expect(page).to have_content('1 Like')
      expect(page).to have_selector('form.button_to .bi-heart-fill')
    end

    it 'user can unlike Rubit' do
      visit root_path
      expect(page).to have_content('This is Rubit')
      expect(page).to have_content('0 Likes')
      expect(page).to have_selector('form.button_to .bi-heart')
      find('form.button_to .bi-heart').click
      expect(page).to have_content('1 Like')
      expect(page).to have_selector('form.button_to .bi-heart-fill')

      find('form.button_to .bi-heart-fill').click
      expect(page).to have_content('0 Likes')
      expect(page).to have_selector('form.button_to .bi-heart')
    end
  end
  context 'when user is not signed in' do
    it 'user cannot like rubit and is redirected ot sign in page' do
      visit root_path
      expect(page).to have_content('This is Rubit')
      expect(page).to have_content('0 Likes')
      expect(page).to have_selector('form.button_to .bi-heart')

      find('form.button_to .bi-heart').click
      expect(page).to have_content('Sign In')
    end
  end
end
