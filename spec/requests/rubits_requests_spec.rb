require 'rails_helper'

RSpec.describe 'Rubits Requests Test', type: :request do
  let(:user) { create(:user) }
  let!(:rubits) { create_list(:rubit, 3, user: user) }
  let(:rubit) { rubits.first }

  describe 'GET #index' do
    it 'renders index and displays rubits' do
      get root_path

      expect(response).to have_http_status(:ok)

      rubits.each do |rubit|
        expect(response.body).to include(rubit.content)
      end
    end

    context 'with page param' do
      it 'renders turbo frame for the requested page' do
        create_list(:rubit, 21, user: user)

        get root_path, params: { page: 2 }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('turbo-frame id="rubits-page-2"')
      end
    end
  end

  describe 'GET #show' do
    it 'renders show with the requested rubit' do
      get rubit_path(rubit)

      expect(response).to have_http_status(:ok)

      expect(response.body).to include('This is an example Rubit number 1')
      expect(response.body).not_to include('This is an example Rubit number 2')
    end
  end

  describe 'POST #create' do
    let(:valid_params) { { rubit: { content: 'New rubit content' } } }
    let(:invalid_params) { { rubit: { content: '' } } }

    context 'when user is not signed in' do
      it 'redirects to sign in page' do
        post rubits_path, params: valid_params
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is signed in' do
      before { sign_in user }

      context 'with valid params' do
        it 'creates a new rubit and responds with turbo stream' do
          expect do
            post rubits_path, params: valid_params, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
          end.to change(Rubit, :count).by(1)

          expect(response.media_type).to eq 'text/vnd.turbo-stream.html'
          expect(response.body).to include('turbo-stream')
          expect(flash.now[:notice]).to eq('Rubit created')
        end

        it 'creates a new rubit and redirects with HTML fallback' do
          expect do
            post rubits_path, params: valid_params
          end.to change(Rubit, :count).by(1)

          expect(response).to redirect_to(root_path)
          follow_redirect!
          expect(response.body).to include('Rubit created')
        end
      end

      context 'with invalid params' do
        it 'does not create rubit and responds with turbo stream' do
          expect do
            post rubits_path, params: invalid_params, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
          end.not_to change(Rubit, :count)

          expect(response.media_type).to eq 'text/vnd.turbo-stream.html'
          expect(response.body).to include('turbo-stream')
          expect(flash.now[:alert]).to eq('Failed to create Rubit')
        end

        it 'does not create rubit and renders new template with HTML fallback' do
          expect do
            post rubits_path, params: invalid_params
          end.not_to change(Rubit, :count)

          expect(response).to redirect_to(root_path)
          follow_redirect!
          expect(response.body).to include('Failed to create Rubit')
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:rubit_to_delete) { create(:rubit, user: user) }

    context 'when user is not signed in' do
      it 'redirects to sign_in' do
        delete rubit_path(rubit_to_delete)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is signed in and Rubit belongs to current_user' do
      before { sign_in user }

      context 'successful deletion' do
        it 'deletes rubit and responds with turbo stream' do
          expect do
            delete rubit_path(rubit_to_delete), headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
          end.to change(Rubit, :count).by(-1)

          expect(response.media_type).to eq 'text/vnd.turbo-stream.html'
          expect(response.body).to include('turbo-stream')
          expect(flash.now[:notice]).to eq('Rubit deleted')
        end

        it 'deletes rubit and redirects with HTML fallback' do
          expect do
            delete rubit_path(rubit_to_delete)
          end.to change(Rubit, :count).by(-1)

          expect(response).to redirect_to(root_path)
          follow_redirect!
          expect(response.body).to include('Rubit deleted')
        end
      end


      context 'failed deletion' do
        before do
          allow_any_instance_of(Rubit).to receive(:destroy).and_return(false)
        end

        it 'does not delete rubit and responds with turbo stream' do
          expect do
            delete rubit_path(rubit_to_delete), headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
          end.not_to change(Rubit, :count)

          expect(response.media_type).to eq 'text/vnd.turbo-stream.html'
          expect(response.body).to include('turbo-stream')
          expect(flash.now[:alert]).to eq('Failed to delete Rubit')
        end


        it 'does not delete rubit and redirects with HTML fallback' do
          expect do
            delete rubit_path(rubit_to_delete)
          end.not_to change(Rubit, :count)

          expect(response).to redirect_to(root_path)
          follow_redirect!
          expect(response.body).to include('Failed to delete Rubit')
        end
      end
    end
    context "when user is signed in but Rubit doesn't belongs to current_user" do
      let(:other_user) { create(:user) }
      let!(:others_rubit) { create(:rubit, user: other_user) }

      before { sign_in user }

      it 'does not delete the rubit and responds with turbo flash' do
        expect do
          delete rubit_path(others_rubit), headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        end.not_to change(Rubit, :count)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('turbo-stream')
        expect(flash[:alert]).to eq('You are not authorized to delete this Rubit')
      end

      it 'does not delete the rubit and redirects with HTML fallback' do
        expect do
          delete rubit_path(others_rubit)
        end.not_to change(Rubit, :count)

        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include('You are not authorized to delete this Rubit')
      end
    end
  end
end
