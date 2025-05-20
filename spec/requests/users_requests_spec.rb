require 'rails_helper'

RSpec.describe 'UsersController', type: :request do
  describe 'GET /account' do
    let(:user) { create(:user) }

    before do
      @root_rubits = create_list(:rubit, 3, user: user)

      parent_rubit = create(:rubit, user: user)
      @child_rubits = create_list(:rubit, 2, user: user, parent_rubit: parent_rubit)

      liked_rubit = create(:rubit, content: 'this is liked rubit')
      create(:like, user: user, rubit: liked_rubit)
    end

    context 'when user is not signed in' do
      it 'redirects to the sign in page' do
        get account_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is signed in' do
      before do
        sign_in user
        get account_path
      end

      it 'redirects to account page' do
        expect(response).to have_http_status(:success)
      end

      it 'includes root rubits content in the response body' do
        @root_rubits.each do |rubit|
          expect(response.body).to include(rubit.content)
        end
      end

      it 'includes liked rubits content in the response body' do
        expect(response.body).to include('this is liked rubit')
      end

      it 'includes child rubits (comments) content in the response body' do
        @child_rubits.each do |rubit|
          expect(response.body).to include(rubit.content)
        end
      end
    end
  end
end
