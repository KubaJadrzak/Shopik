require 'rails_helper'

RSpec.describe 'Rubit Like System Test', type: :system do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let!(:rubit) { create(:rubit, content: 'This is an example Rubit number 1', user: other_user) }

  context 'Rubit Creation Form' do
    context 'when user is authorized' do
      before do
        sign_in user
      end

      it 'creates rubit with valid content' do
        visit root_path
        expect(page).to have_content('This is an example Rubit number 1')

        within '#new_rubit_form' do
          fill_in 'rubit_content', with: 'This is my rubit'
          find('button.btn-comment').click
        end

        expect(page).to have_content('Rubit created', wait: 3)
        expect(page).to have_content('This is my rubit', wait: 3)
      end

      it "doesn't create rubit with invalid content and shows error message" do
        visit root_path
        within '#new_rubit_form' do
          fill_in 'rubit_content', with: '   '
          find('button.btn-comment').click
        end

        expect(page).to have_content('Failed to create Rubit', wait: 3)
      end
    end

    context 'when user is unauthorized' do
      it "doesn't create rubit with valid content and redirects to login page and shows error message" do
        visit root_path

        within '#new_rubit_form' do
          fill_in 'rubit_content', with: 'This is my rubit'
          find('button.btn-comment').click
        end

        expect(page).to have_current_path(new_user_session_path, wait: 3)
        expect(page).to have_content('You need to sign in or sign up before continuing.', wait: 3)
      end
    end
  end
  context 'Rubit Delete Button' do
    before do
      sign_in user
    end

    it 'is visible only when Rubit does belong to current user' do
      visit root_path
      expect(page).to have_content('This is an example Rubit number 1')
      expect(page).not_to have_selector('button.btn.btn-sm.text-dark.p-1', wait: 3)

      within '#new_rubit_form' do
        fill_in 'rubit_content', with: 'This is my rubit'
        find('button.btn-comment').click
      end

      expect(page).to have_content('Rubit created', wait: 3)
      expect(page).to have_content('This is my rubit', wait: 3)
      expect(page).to have_selector('button.btn.btn-sm.text-dark.p-1', wait: 3)
    end

    it 'allows to delete Rubit' do
      visit root_path

      within '#new_rubit_form' do
        fill_in 'rubit_content', with: 'This is my rubit'
        find('button.btn-comment').click
      end

      expect(page).to have_content('Rubit created', wait: 3)
      expect(page).to have_content('This is my rubit', wait: 3)

      find('button.btn.btn-sm.text-dark.p-1', wait: 3).click

      expect(page).to have_content('Rubit deleted', wait: 3)
      expect(page).not_to have_selector('button.btn.btn-sm.text-dark.p-1', wait: 3)
    end
  end

  context 'Rubit Like Button' do

    context 'when user is authorized' do
      before do
        sign_in user
      end
      it 'allows to add and remove a like to/from rubit' do
        visit root_path

        expect(page).to have_content('This is an example Rubit number 1')

        expect(page).to have_selector('i.bi-heart', wait: 3)
        find('form.button_to button.btn', wait: 3).click

        expect(page).to have_selector('i.bi-heart-fill', wait: 3)
        expect(page).to have_content('1 Like')

        find('form.button_to button.btn', wait: 3).click

        expect(page).to have_selector('i.bi-heart', wait: 3)
        expect(page).to have_content('0 Likes')
      end
    end
    context 'when user is unauthorized' do
      it 'redirects to login page' do
        visit root_path

        expect(page).to have_content('This is an example Rubit number 1')

        expect(page).to have_selector('i.bi-heart', wait: 3)
        find('form.button_to button.btn', wait: 3).click

        expect(page).to have_current_path(new_user_session_path, wait: 3)
        expect(page).to have_content('You need to sign in or sign up before continuing.', wait: 3)
      end
    end
  end
end
