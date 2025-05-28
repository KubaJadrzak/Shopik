require 'rails_helper'


RSpec.describe 'Rubits System Test', type: :system do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let!(:rubit) { create(:rubit, content: 'This is Rubit', user: other_user) }
  let!(:another_rubit) { create(:rubit, content: 'This is another Rubit', user: other_user) }

  context 'when user is signed in' do
    before do
      sign_in user
    end
    it 'user can add rubit' do
      visit root_path
      expect(page).to_not have_content('This is my test Rubit')

      within('turbo-frame#new_rubit_form') do
        fill_in 'rubit_content', with: 'This is my test Rubit'
        click_button(type: 'submit')
      end

      expect(page).to have_content('Rubit created')
      expect(page).to have_content('This is my test Rubit')
    end

    it 'user can add comment to rubit' do
      visit root_path
      expect(page).to have_content('This is Rubit')
      expect(page).to have_content('This is another Rubit')
      find('a', text: /This is Rubit/).click

      expect(page).to have_selector('turbo-frame#new_rubit_form', wait: 3)
      expect(page).to_not have_content('This is another Rubit', wait: 3)
      within('turbo-frame#new_rubit_form') do
        fill_in 'rubit_content', with: 'This is my test Rubit comment'
        click_button(type: 'submit')
      end

      expect(page).to have_content('Rubit created')
      expect(page).to have_content('This is my test Rubit comment', wait: 3)

    end

    it 'user can delete their own Rubit' do
      visit root_path
      expect(page).to_not have_content('This is my test Rubit')

      within('turbo-frame#new_rubit_form') do
        fill_in 'rubit_content', with: 'This is my test Rubit'
        click_button(type: 'submit')
      end

      expect(page).to have_content('Rubit created')
      expect(page).to have_content('This is my test Rubit')

      find('form.button_to .bi-trash').click
      expect(page).to_not have_content('This is my test Rubit')
    end

    it 'user cannot delete other users rubits' do
      visit root_path
      expect(page).to_not have_content('This is my test Rubit')
      expect(page).to_not have_selector('form.button_to .bi-trash')
      expect(page).to_not have_content('This is my test Rubit')
    end
  end

  context 'when user is not signed in' do

    it 'user can visit Rubits index page' do
      visit root_path
      expect(page).to have_content('This is Rubit')
      expect(page).to have_content('This is another Rubit')
    end

    it 'user can visit rubit show page' do
      visit root_path
      expect(page).to have_content('This is Rubit')
      expect(page).to have_content('This is another Rubit')
      find('a', text: /This is Rubit/).click

      expect(page).to have_selector('turbo-frame#new_rubit_form', wait: 3)
      expect(page).to_not have_content('This is another Rubit', wait: 3)
    end
    it 'user cannot add Rubit and is redirected to sign in page' do
      visit root_path
      expect(page).to_not have_content('This is my test Rubit')

      within('turbo-frame#new_rubit_form') do
        fill_in 'rubit_content', with: 'This is my test Rubit'
        click_button(type: 'submit')
      end

      expect(page).to have_content('Sign In')
    end

    it 'user cannot comment on rubit and is redirected to sign in page' do
      visit root_path
      expect(page).to have_content('This is Rubit')
      expect(page).to have_content('This is another Rubit')
      find('a', text: /This is Rubit/).click

      expect(page).to have_selector('turbo-frame#new_rubit_form', wait: 3)
      expect(page).to_not have_content('This is another Rubit', wait: 3)

      within('turbo-frame#new_rubit_form') do
        fill_in 'rubit_content', with: 'This is my test Rubit'
        click_button(type: 'submit')
      end

      expect(page).to have_content('Sign In')
    end
  end
end
