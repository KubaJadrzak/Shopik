require 'rails_helper'

RSpec.describe 'Espago::BackRequestsController Requests Test', type: :request do
  let(:login_basic_auth) { Rails.application.credentials.dig(:espago, :login_basic_auth) }
  let(:password_basic_auth) { Rails.application.credentials.dig(:espago, :password_basic_auth) }
  let(:headers) do
    {
      'CONTENT_TYPE'  => 'application/json',
      'ACCEPT'        => 'application/json',
      'Authorization' => ActionController::HttpAuthentication::Basic.encode_credentials(login_basic_auth,
                                                                                        password_basic_auth,),
    }
  end

  describe 'POST /espago/back_request' do
    let(:payment_id) { 'espago_123' }
    let(:payment_number) { 'E2A46240ADC041537175' }
    let(:success_payload) do
      {
        id:                   payment_id,
        state:                'executed',
        description:          "Payment ##{payment_number}",
        issuer_response_code: '00',
      }
    end
    let(:fail_payload) do
      {
        id:                   payment_id,
        state:                'failed',
        description:          "Payment ##{payment_number}",
        issuer_response_code: '99',
        reject_reason:        '3ds',
        behaviour:            '3ds required',
      }
    end

    context 'with valid credentials' do
      context 'when payment is successful' do
        context 'when the payment belongs to order' do
          let!(:order) { create(:order) }
          let!(:payment) do
            create(:payment, :for_order, payable: order, payment_id: payment_id, payment_number: payment_number)
          end

          it 'updates the status of payment and order and returns :ok' do
            post '/espago/back_request', params: success_payload, headers: headers, as: :json

            expect(response).to have_http_status(:ok)
            expect(order.reload.status).to eq('Preparing for Shipment')
            expect(payment.reload.state).to eq('executed')
          end
        end

        context 'when the payment belongs to subscription' do
          let!(:subscription) { create(:subscription) }
          let!(:payment) do
            create(:payment, :for_subscription, payable: subscription, payment_id: payment_id,
                                                                            payment_number: payment_number,)
          end

          it 'updates the status of payment and subscription and returns :ok' do
            post '/espago/back_request', params: success_payload, headers: headers, as: :json

            expect(response).to have_http_status(:ok)
            expect(subscription.reload.status).to eq('Active')
            expect(payment.reload.state).to eq('executed')
          end
        end
      end
      context 'when payment failed' do
        context 'when the payment belongs to order' do
          let!(:order) { create(:order) }
          let!(:payment) do
            create(:payment, :for_order, payable: order, payment_id: payment_id, payment_number: payment_number)
          end

          it 'updates the status of payment and order, updated payment fail related fields and returns :ok' do
            post '/espago/back_request', params: fail_payload, headers: headers, as: :json

            expect(response).to have_http_status(:ok)
            expect(order.reload.status).to eq('Payment Failed')
            payment.reload
            expect(payment.state).to eq('failed')
            expect(payment.issuer_response_code).to eq('99')
            expect(payment.reject_reason).to eq('3ds')
            expect(payment.behaviour).to eq('3ds required')
          end
        end

        context 'when the payment belongs to subscription' do
          let!(:subscription) { create(:subscription) }
          let!(:payment) do
            create(:payment, :for_subscription, payable: subscription, payment_id: payment_id,
payment_number: payment_number,)
          end

          it 'updates the status of payment and subscription, updated payment fail related fields and returns :ok' do
            post '/espago/back_request', params: fail_payload, headers: headers, as: :json

            expect(response).to have_http_status(:ok)
            expect(subscription.reload.status).to eq('Payment Failed')
            payment.reload
            expect(payment.state).to eq('failed')
            expect(payment.issuer_response_code).to eq('99')
            expect(payment.reject_reason).to eq('3ds')
            expect(payment.behaviour).to eq('3ds required')
          end
        end
      end

      context 'when the payment does not exist' do
        it 'returns :not_found and does not raise error' do
          post '/espago/back_request', params: success_payload, headers: headers, as: :json
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when the payment does not have a payment_id but exists by payment_number in description' do
      let!(:order) { create(:order) }
      let!(:payment) { create(:payment, :for_order, payable: order, payment_id: nil) }
      let(:payload) do
        {
          id:          payment_id,
          state:       'executed',
          description: "Payment ##{payment.payment_number}",
        }
      end

      it 'assigns payment_id, updates the statuses, and returns :ok' do
        post '/espago/back_request', params: payload, headers: headers, as: :json

        expect(response).to have_http_status(:ok)
        expect(order.reload.status).to eq('Preparing for Shipment')
        payment.reload
        expect(payment.state).to eq('executed')
        expect(payment.payment_id).to eq(payment_id)
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
        post '/espago/back_request', params: success_payload, headers: headers, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
