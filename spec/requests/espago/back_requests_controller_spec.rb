# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BackRequestsController, type: :request do
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

  let(:payment_id) { 'espago_123' }
  let(:uuid) { 'E2A46240ADC041537175' }
  let(:client_id) { 'cli_9cbbpQpSUgQo4BGp' }
  let(:card_data) do
    {
      'card' => {
        'last4'      => '4242',
        'company'    => 'Visa',
        'first_name' => 'John',
        'last_name'  => 'Doe',
        'year'       => '2026',
        'month'      => '12',
      },
    }
  end

  # Base payloads
  let(:success_payload) do
    {
      id:                   payment_id,
      state:                'executed',
      description:          "Payment ##{uuid}",
      client:               client_id,
      issuer_response_code: '00',
    }.merge(card_data)
  end

  let(:success_cit_payload) do
    {
      id:                   payment_id,
      state:                'executed',
      description:          "Payment ##{uuid} - cit",
      client:               client_id,
      issuer_response_code: '00',
    }.merge(card_data)
  end

  let(:success_mit_payload) do
    {
      id:                   payment_id,
      state:                'executed',
      description:          "Payment ##{uuid} - mit",
      client:               client_id,
      issuer_response_code: '00',
    }.merge(card_data)
  end

  let(:success_storing_payload) do
    {
      id:                   payment_id,
      state:                'executed',
      description:          "Payment ##{uuid} - storing",
      client:               client_id,
      issuer_response_code: '00',
    }.merge(card_data)
  end

  let(:fail_payload) do
    {
      id:                   payment_id,
      state:                'failed',
      description:          "Payment ##{uuid}",
      client:               client_id,
      issuer_response_code: '99',
      reject_reason:        '3ds',
      behaviour:            '3ds required',
    }.merge(card_data)
  end
  let(:fail_storing_payload) do
    {
      id:                   payment_id,
      state:                'failed',
      description:          "Payment ##{uuid} - storing",
      client:               client_id,
      issuer_response_code: '99',
      reject_reason:        '3ds',
      behaviour:            '3ds required',
    }.merge(card_data)
  end

  let(:fail_cit_payload) do
    {
      id:                   payment_id,
      state:                'failed',
      description:          "Payment ##{uuid} - cit",
      client:               client_id,
      issuer_response_code: '99',
      reject_reason:        '3ds',
      behaviour:            '3ds required',
    }.merge(card_data)
  end

  let(:fail_mit_payload) do
    {
      id:                   payment_id,
      state:                'failed',
      description:          "Payment ##{uuid} - mit",
      client:               client_id,
      issuer_response_code: '99',
      reject_reason:        '3ds',
      behaviour:            '3ds required',
    }.merge(card_data)
  end

  describe 'POST /espago/back_request' do

    context 'with valid credentials' do
      context 'when payment is successful' do
        context 'when payment is standalone' do
          context 'when the payment belongs to order' do
            let!(:order) { create(:order) }
            let!(:payment) do
              create(:payment, :for_order, payable: order, payment_id: payment_id, uuid: uuid)
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
  uuid: uuid,)
            end

            it 'updates the status of payment and subscription and returns :ok' do
              post '/espago/back_request', params: success_payload, headers: headers, as: :json

              expect(response).to have_http_status(:ok)
              expect(subscription.reload.status).to eq('Active')
              expect(payment.reload.state).to eq('executed')
            end
          end
        end
        context 'when payment is storing' do
          let!(:order) { create(:order) }
          let!(:payment) do
            create(:payment, :for_order, payable: order, payment_id: payment_id,
        uuid: uuid,)
          end
          it 'updates the status of payment and payable and creates a new client' do
            post '/espago/back_request', params: success_storing_payload, headers: headers, as: :json

            expect(response).to have_http_status(:ok)
            expect(order.reload.status).to eq('Preparing for Shipment')
            expect(payment.reload.state).to eq('executed')

            client = ::Client.first
            expect(client.reload.client_id).to eq(client_id)
          end
        end
        context 'when payment is CIT' do
          let!(:order) { create(:order) }
          let!(:payment) do
            create(:payment, :for_order, payable: order, payment_id: payment_id,
        uuid: uuid,)
          end
          let!(:client) { create(:client, client_id: client_id) }
          it 'updates the status of payment and payable and assigns payment to client' do
            post '/espago/back_request', params: success_cit_payload, headers: headers, as: :json

            expect(response).to have_http_status(:ok)
            expect(order.reload.status).to eq('Preparing for Shipment')
            expect(payment.reload.state).to eq('executed')

            expect(client.reload.payments).to include(payment)
          end
        end

        context 'when payment is MIT' do
          let!(:order) { create(:order) }
          let!(:payment) do
            create(:payment, :for_client, payable: client, payment_id: payment_id,
        uuid: uuid,)
          end
          let!(:client) { create(:client, client_id: client_id) }
          it 'updates the status of payment and payable, assigns payment to client and updates client status to MIT' do
            post '/espago/back_request', params: success_mit_payload, headers: headers, as: :json

            expect(response).to have_http_status(:ok)
            expect(client.reload.payments).to include(payment)
            expect(client.reload.status).to eq('MIT')
          end

        end
      end
      context 'when payment failed' do

        context 'when payment is standalone' do
          context 'when the payment belongs to order' do
            let!(:order) { create(:order) }
            let!(:payment) do
              create(:payment, :for_order, payable: order, payment_id: payment_id, uuid: uuid)
            end

            it 'updates the status of payment and order, updates payment fail fields and returns :ok' do
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
            let!(:subscription) { create(:subscription,  start_date: nil, end_date: nil, status: 'New') }
            let!(:payment) do
              create(:payment, :for_subscription, payable: subscription, payment_id: payment_id,
              uuid: uuid,)
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
        context 'when payment is storing' do
          let!(:order) { create(:order) }
          let!(:payment) do
            create(:payment, :for_order, payable: order, payment_id: payment_id,
        uuid: uuid,)
          end
          it 'updates the status of payment and payable and does not create a new client' do
            post '/espago/back_request', params: fail_storing_payload, headers: headers, as: :json

            expect(response).to have_http_status(:ok)
            expect(order.reload.status).to eq('Payment Failed')
            expect(payment.reload.state).to eq('failed')

            client = ::Client.first
            expect(client).to be nil
          end
        end
        context 'when payment is CIT' do
          let!(:order) { create(:order) }
          let!(:payment) do
            create(:payment, :for_order, payable: order, payment_id: payment_id,
        uuid: uuid,)
          end
          let!(:client) { create(:client, client_id: client_id) }
          it 'updates the status of payment and payable and assigns payment to client' do
            post '/espago/back_request', params: fail_cit_payload, headers: headers, as: :json

            expect(response).to have_http_status(:ok)
            expect(order.reload.status).to eq('Payment Failed')
            expect(payment.reload.state).to eq('failed')

            expect(client.reload.payments).to include(payment)
          end
        end
        context 'when payment is MIT' do
          let!(:order) { create(:order) }
          let!(:payment) do
            create(:payment, :for_order, payable: order, payment_id: payment_id,
        uuid: uuid,)
          end
          let!(:client) { create(:client, client_id: client_id, status: 'MIT') }
          it 'updates the status of payment and payable, assigns payment to client and updates client status to CIT' do
            post '/espago/back_request', params: fail_mit_payload, headers: headers, as: :json

            expect(response).to have_http_status(:ok)
            expect(order.reload.status).to eq('Payment Failed')
            expect(payment.reload.state).to eq('failed')

            expect(client.reload.payments).to include(payment)
            expect(client.reload.status).to eq('CIT')
          end
        end
      end

      context 'when the payment does not exist' do
        it 'returns :not_found and does not raise error' do
          post '/espago/back_request', params: success_payload, headers: headers, as: :json
          expect(response).to have_http_status(:not_found)
        end
      end
      context 'when payment_id doesnt match any payment, but uuid matches known payment' do
        let!(:order) { create(:order) }
        let!(:payment) { create(:payment, :for_order, payable: order, payment_id: nil) }
        let(:payload) do
          {
            id:          payment_id,
            state:       'executed',
            description: "Payment ##{payment.uuid}",
          }
        end

        it 'assigns payment_id, updates the statuses, returns :ok' do
          post '/espago/back_request', params: payload, headers: headers, as: :json

          expect(response).to have_http_status(:ok)
          expect(order.reload.status).to eq('Preparing for Shipment')
          payment.reload
          expect(payment.state).to eq('executed')
          expect(payment.payment_id).to eq(payment_id)
        end
      end
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
