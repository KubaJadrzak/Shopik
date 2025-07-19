require 'rails_helper'

RSpec.describe 'LikesController Requests Test', type: :request do
  let(:user) { create(:user) }
  let(:rubit) { create(:rubit) }

  describe 'POST /rubits/:rubit_id/like' do
    context 'when user is not signed in' do
      it 'redirects to sign in page' do
        post rubit_likes_path(rubit)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is signed in' do
      before { sign_in user }

      it 'creates a like and renders turbo stream response' do
        expect do
          post rubit_likes_path(rubit), headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' }
        end.to change { rubit.likes.count }
          .by(1)

        expect(response.media_type).to eq 'text/vnd.turbo-stream.html'
        expect(response.body).to include("rubit_#{rubit.id}_like_section")
      end

      it 'creates a like and redirects with HTML fallback' do
        expect do
          post rubit_likes_path(rubit)
        end.to change { rubit.likes.count }
          .by(1)

        expect(response).to redirect_to(root_path).or redirect_to(/http/)
        follow_redirect!
        expect(response.body).to include(rubit.content)
      end
    end
  end

  describe 'DELETE /rubits/:rubit_id/likes/:id' do
    context 'when user is not signed in' do
      let!(:like) { create(:like, user: user, rubit: rubit) }

      it 'redirects to sign in page' do
        delete rubit_like_path(rubit, like)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is signed in and has liked the rubit' do
      let!(:like) { create(:like, user: user, rubit: rubit) }

      before { sign_in user }

      it 'deletes the like and renders turbo stream response' do
        expect do
          delete rubit_like_path(rubit, like), headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' }
        end.to change { rubit.likes.count }
          .by(-1)

        expect(response.media_type).to eq 'text/vnd.turbo-stream.html'
        expect(response.body).to include("rubit_#{rubit.id}_like_section")
      end

      it 'deletes the like and redirects with HTML fallback' do
        expect do
          delete rubit_like_path(rubit, like)
        end.to change { rubit.likes.count }
          .by(-1)

        expect(response).to redirect_to(root_path).or redirect_to(/http/)
        follow_redirect!
        expect(response.body).to include(rubit.content)
      end
    end
  end
end
