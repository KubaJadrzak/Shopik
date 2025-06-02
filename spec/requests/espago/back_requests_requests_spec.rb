require 'rails_helper'

RSpec.describe 'Espago::BackRequestsController Requests Test', type: :request do
  let(:app_id) { Rails.application.credentials.dig(:espago, :app_id) }
  let(:password) { Rails.application.credentials.dig(:espago, :password) }
  let(:headers) do
    {
      'CONTENT_TYPE'  => 'application/json',
      'ACCEPT'        => 'application/json',
      'Authorization' => ActionController::HttpAuthentication::Basic.encode_credentials(app_id, password),
    }
  end

  describe 'POST /espago/back_request' do
    let(:payment_id) { 'espago_123' }
    let(:payload) do
      {
        id:    payment_id,
        state: 'executed',
      }
    end

    context 'with valid credentials' do
      context 'when the order exists' do
        let!(:order) { create(:order, payment_id: payment_id) }

        it 'updates the order status and returns :ok' do
          post '/espago/back_request', params: payload.to_json, headers: headers

          expect(response).to have_http_status(:ok)
          expect(order.reload.status).to eq('Preparing for Shipment')
          expect(order.payment_status).to eq('executed')
        end
      end

      context 'when the order does not exist' do
        it 'returns :not_found and does not raise error' do
          post '/espago/back_request', params: payload.to_json, headers: headers

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'with invalid credentials' do
      let(:headers) do
        {
          'CONTENT_TYPE'  => 'application/json',
          'ACCEPT'        => 'application/json',
          'Authorization' => ActionController::HttpAuthentication::Basic.encode_credentials('app_id', 'password'),
        }
      end

      it 'returns :unauthorized' do
        post '/espago/back_request', params: payload.to_json, headers: headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
