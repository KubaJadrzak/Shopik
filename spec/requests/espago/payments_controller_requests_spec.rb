require 'rails_helper'

RSpec.describe Espago::PaymentsController, type: :request do
  let(:user) { create(:user) }
  let(:order) { create(:order, user: user) }
  let!(:card_token) { 'cc_1234' }

  before { sign_in user }

  describe 'GET /espago/payments/:id/start_payment' do
    context 'Secure Web Page' do
      context 'when payment is successfully created' do
        let(:response_body) { { 'id' => 'espago_123', 'redirect_url' => 'https://payment.example.com/redirect' } }

        before do
          service = instance_double(Espago::SecureWebPageService)
          response = Espago::Response.new(success: true, status: 200, body: response_body)
          allow(Espago::SecureWebPageService).to receive(:new).with(order).and_return(service)
          allow(service).to receive(:create_payment).and_return(response)

          get "/espago/payments/#{order.id}/start_payment"
        end

        it 'updates the payment_id and redirects to payment gateway' do
          expect(order.reload.payment_id).to eq('espago_123')
          expect(response).to redirect_to('https://payment.example.com/redirect')
        end
      end

      context 'when payment creation fails with uncertain error' do
        before do
          service = instance_double(Espago::SecureWebPageService)
          response = Espago::Response.new(success: false, status: :timeout, body: {})
          allow(Espago::SecureWebPageService).to receive(:new).with(order).and_return(service)
          allow(service).to receive(:create_payment).and_return(response)

          get "/espago/payments/#{order.id}/start_payment"
        end

        it 'updates the order status and redirects to payments/awaiting' do
          expect(order.reload.status).to eq('Awaiting Payment')
          expect(order.payment_status).to eq('timeout')
          expect(response).to redirect_to(espago_payments_awaiting_path(order))
        end
      end
      context 'when payment creation fails' do
        before do
          service = instance_double(Espago::SecureWebPageService)
          response = Espago::Response.new(success: false, status: 401, body: {})
          allow(Espago::SecureWebPageService).to receive(:new).with(order).and_return(service)
          allow(service).to receive(:create_payment).and_return(response)

          get "/espago/payments/#{order.id}/start_payment"
        end

        it 'updates the order status and redirects order show view' do
          expect(order.reload.status).to eq('Payment Error')
          expect(order.payment_status).to eq('401')
          expect(response).to redirect_to(order_path(order))
        end
      end
    end
    context 'One Time Payment' do
      context 'when payment is successfully created and contains 3ds redirect_url' do
        let(:response_body) { { 'id' => 'espago_123', 'redirect_url' => 'https://payment.example.com/redirect' } }
        let(:card_token) { 'test_card_token_123' }

        before do
          allow_any_instance_of(Espago::PaymentsController).to receive(:session).and_return(
            double('session', delete: card_token),
          )

          service = instance_double(Espago::OneTimePaymentService)
          response = Espago::Response.new(success: true, status: 200, body: response_body)
          allow(Espago::OneTimePaymentService).to receive(:new)
            .with(card_token: card_token, order: order)
            .and_return(service)
          allow(service).to receive(:create_payment).and_return(response)

          get "/espago/payments/#{order.id}/start_payment"
        end

        it 'updates the payment_id and redirects to 3ds gateway' do
          expect(order.reload.payment_id).to eq('espago_123')
          expect(response).to redirect_to('https://payment.example.com/redirect')
        end
      end
      context 'when payment is successfully created and contains dcc redirect' do
        let(:response_body) { { 'id' => 'espago_123', 'dcc_decision_information' => { 'redirect_url' => 'https://payment.example.com/redirect' } } }
        let(:card_token) { 'test_card_token_123' }

        before do
          allow_any_instance_of(Espago::PaymentsController).to receive(:session).and_return(
            double('session', delete: card_token),
          )

          service = instance_double(Espago::OneTimePaymentService)
          response = Espago::Response.new(success: true, status: 200, body: response_body)
          allow(Espago::OneTimePaymentService).to receive(:new)
            .with(card_token: card_token, order: order)
            .and_return(service)
          allow(service).to receive(:create_payment).and_return(response)

          get "/espago/payments/#{order.id}/start_payment"
        end

        it 'updates the payment_id and redirects to dcc gateway' do
          expect(order.reload.payment_id).to eq('espago_123')
          expect(response).to redirect_to('https://payment.example.com/redirect')
        end
      end
      context 'when payment is created with executed state' do
        let(:response_body) { { 'id' => 'espago_123', 'state' => 'executed' } }
        let(:card_token) { 'test_card_token_123' }

        before do
          allow_any_instance_of(Espago::PaymentsController).to receive(:session).and_return(
            double('session', delete: card_token),
          )

          service = instance_double(Espago::OneTimePaymentService)
          response = Espago::Response.new(success: true, status: 200, body: response_body)
          allow(Espago::OneTimePaymentService).to receive(:new)
            .with(card_token: card_token, order: order)
            .and_return(service)
          allow(service).to receive(:create_payment).and_return(response)

          get "/espago/payments/#{order.id}/start_payment"
        end

        it 'updates the payment_id and redirects to payments success path' do
          order.reload
          expect(order.payment_id).to eq('espago_123')
          expect(response).to redirect_to(espago_payments_success_path(order))
        end
      end
      %w[preauthorized
         tds2_challenge
         tds_redirected
         dcc_decision
         blik_redirected
         transfer_redirected
         new].each do |status|
        context "when payment is created with #{status} state" do
          let(:response_body) { { 'id' => 'espago_123', 'state' => status } }
          let(:card_token) { 'test_card_token_123' }

          before do
            allow_any_instance_of(Espago::PaymentsController).to receive(:session).and_return(
              double('session', delete: card_token),
            )

            service = instance_double(Espago::OneTimePaymentService)
            response = Espago::Response.new(success: true, status: 200, body: response_body)
            allow(Espago::OneTimePaymentService).to receive(:new)
              .with(card_token: card_token, order: order)
              .and_return(service)
            allow(service).to receive(:create_payment).and_return(response)

            get "/espago/payments/#{order.id}/start_payment"
          end

          it 'updates the payment_id and redirects to awaiting path' do
            order.reload
            expect(order.payment_id).to eq('espago_123')
            expect(response).to redirect_to(espago_payments_awaiting_path(order))
          end
        end
      end
      %w[rejected failed resigned reversed].each do |status|
        context "when payment is created with #{status} state" do
          let(:response_body) { { 'id' => 'espago_123', 'state' => status } }
          let(:card_token) { 'test_card_token_123' }

          before do
            allow_any_instance_of(Espago::PaymentsController).to receive(:session).and_return(
              double('session', delete: card_token),
            )

            service = instance_double(Espago::OneTimePaymentService)
            response = Espago::Response.new(success: true, status: 200, body: response_body)
            allow(Espago::OneTimePaymentService).to receive(:new)
              .with(card_token: card_token, order: order)
              .and_return(service)
            allow(service).to receive(:create_payment).and_return(response)

            get "/espago/payments/#{order.id}/start_payment"
          end

          it 'updates the payment_id and redirects to failure path' do
            order.reload
            expect(order.payment_id).to eq('espago_123')
            expect(response).to redirect_to(espago_payments_failure_path(order))
          end
        end
      end
      context 'when payment fails with uncertain error' do
        let(:card_token) { 'test_card_token_123' }

        before do
          allow_any_instance_of(Espago::PaymentsController).to receive(:session).and_return(
            double('session', delete: card_token),
          )

          service = instance_double(Espago::OneTimePaymentService)
          response = Espago::Response.new(success: false, status: :timeout, body: {})
          allow(Espago::OneTimePaymentService).to receive(:new)
            .with(card_token: card_token, order: order)
            .and_return(service)
          allow(service).to receive(:create_payment).and_return(response)

          get "/espago/payments/#{order.id}/start_payment"
        end

        it 'updates the order status and redirects to payments/awaiting' do
          expect(order.reload.status).to eq('Awaiting Payment')
          expect(order.payment_status).to eq('timeout')
          expect(response).to redirect_to(espago_payments_awaiting_path(order))
        end
      end

      context 'when payment fails' do
        let(:card_token) { 'test_card_token_123' }

        before do
          allow_any_instance_of(Espago::PaymentsController).to receive(:session).and_return(
            double('session', delete: card_token),
          )

          service = instance_double(Espago::OneTimePaymentService)
          response = Espago::Response.new(success: false, status: 401, body: {})
          allow(Espago::OneTimePaymentService).to receive(:new)
            .with(card_token: card_token, order: order)
            .and_return(service)
          allow(service).to receive(:create_payment).and_return(response)

          get "/espago/payments/#{order.id}/start_payment"
        end

        it 'updates the order status and redirects to order show page' do
          expect(order.reload.status).to eq('Payment Error')
          expect(order.payment_status).to eq('401')
          expect(response).to redirect_to(order_path(order))
        end
      end
    end
  end

  describe 'GET /espago/payments/success' do
    context 'when the order exists' do
      it 'redirects to the order page with success message' do
        get '/espago/payments/success', params: { order_number: order.order_number }

        expect(response).to redirect_to(order_path(order))
        expect(flash[:notice]).to eq('Payment successful!')
      end
    end

    context 'when the order does not exist' do
      it 'redirects to account orders section with alert' do
        get '/espago/payments/success', params: { order_number: 'invalid' }

        expect(response).to redirect_to("#{account_path}#orders")
        expect(flash[:alert]).to eq('We are experiencing an issue with your order')
      end
    end
  end

  describe 'GET /espago/spayments/failure' do
    context 'when the order exists' do
      it 'redirects to the order page with failure message' do
        get '/espago/payments/failure', params: { order_number: order.order_number }

        expect(response).to redirect_to(order_path(order))
        expect(flash[:alert]).to eq('Payment failed!')
      end
    end

    context 'when the order does not exist' do
      it 'redirects to account orders section with alert' do
        get '/espago/payments/failure', params: { order_number: 'invalid' }

        expect(response).to redirect_to("#{account_path}#orders")
        expect(flash[:alert]).to eq('We are experiencing an issue with your order')
      end
    end
  end
end
