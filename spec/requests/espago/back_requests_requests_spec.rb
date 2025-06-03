require 'rails_helper'

RSpec.describe 'Espago::BackRequestsController Requests Test', type: :request do
  let(:app_id) { Rails.application.credentials.dig(:espago, :login_basic_auth) }
  let(:password) { Rails.application.credentials.dig(:espago, :password_basic_auth) }
  let(:headers) do
    {
      'CONTENT_TYPE'  => 'application/json',
      'ACCEPT'        => 'application/json',
      'Authorization' => ActionController::HttpAuthentication::Basic.encode_credentials(app_id, password),
    }
  end

  describe 'POST /espago/back_request' do
    let(:payment_id) { 'espago_123' }
    let(:order_number) { 'E2A46240ADC041537175' }
    let(:payload) do
      {
        id:          payment_id,
        state:       'executed',
        description: "Payment for Order ##{order_number}",
      }
    end

    context 'with valid credentials' do
      context 'when the order exists' do
        let!(:order) { create(:order, payment_id: payment_id) }

        it 'updates the order status and returns :ok' do
          post '/espago/back_request', params: payload, headers: headers, as: :json

          expect(response).to have_http_status(:ok)
          expect(order.reload.status).to eq('Preparing for Shipment')
          expect(order.payment_status).to eq('executed')
        end
      end

      context 'when the order does not exist' do
        it 'returns :not_found and does not raise error' do
          post '/espago/back_request', params: payload, headers: headers, as: :json
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when the order does not have a payment_id but exists by order_number in description' do
      let!(:order) { create(:order, payment_id: nil) }
      let(:order_number) { order.order_number }
      let(:payload) do
        {
          id:          payment_id,
          state:       'executed',
          description: "Payment for Order ##{order_number}",
        }
      end

      it 'assigns payment_id, updates the order status, and returns :ok' do
        post '/espago/back_request', params: payload, headers: headers, as: :json

        expect(response).to have_http_status(:ok)
        expect(order.reload.payment_id).to eq(payment_id)
        expect(order.status).to eq('Preparing for Shipment')
        expect(order.payment_status).to eq('executed')
      end
    end

    context 'with invalid credentials' do
      let(:headers) do
        {
          'CONTENT_TYPE'  => 'application/json',
          'ACCEPT'        => 'application/json',
          'Authorization' => ActionController::HttpAuthentication::Basic.encode_credentials('login_basic_auth',
                                                                                            'password_basic_auth',),
        }
      end

      it 'returns :unauthorized' do
        post '/espago/back_request', params: payload, headers: headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
