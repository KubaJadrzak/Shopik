# spec/requests/espago/secure_web_page/payments_requests_spec.rb
require 'rails_helper'

RSpec.describe Espago::SecureWebPage::PaymentsController, type: :request do
  let(:user) { create(:user) }
  let(:order) { create(:order, user: user) }

  before { sign_in user }

  describe 'GET /espago/secure_web_page/payments/:id/start_payment' do
    context 'when payment is successfully created' do
      let(:response_body) { { 'id' => 'espago_123', 'redirect_url' => 'https://payment.example.com/redirect' } }

      before do
        service = instance_double(Espago::SecureWebPageService)
        response = Espago::Response.new(success: true, status: 200, body: response_body)
        allow(Espago::SecureWebPageService).to receive(:new).with(order).and_return(service)
        allow(service).to receive(:create_payment).and_return(response)

        get "/espago/secure_web_page/payments/#{order.id}/start_payment"
      end

      it 'updates the payment_id and redirects to payment gateway' do
        expect(order.reload.payment_id).to eq('espago_123')
        expect(response).to redirect_to('https://payment.example.com/redirect')
      end
    end

    context 'when payment creation fails' do
      before do
        service = instance_double(Espago::SecureWebPageService)
        response = Espago::Response.new(success: false, status: :connection_failed, body: {})
        allow(Espago::SecureWebPageService).to receive(:new).with(order).and_return(service)
        allow(service).to receive(:create_payment).and_return(response)

        get "/espago/secure_web_page/payments/#{order.id}/start_payment"
      end

      it 'updates the order status and redirects back to order page with alert' do
        expect(order.reload.status).to eq('Payment Error')
        expect(response).to redirect_to(order_path(order))
        expect(flash[:alert]).to eq('We could not process your payment due to a technical issue')
      end
    end
  end


  describe 'GET /espago/secure_web_page/payments/success' do
    context 'when the order exists' do
      it 'redirects to the order page with success message' do
        get '/espago/secure_web_page/payments/success', params: { order_number: order.order_number }

        expect(response).to redirect_to(order_path(order))
        expect(flash[:notice]).to eq('Payment successful!')
      end
    end

    context 'when the order does not exist' do
      it 'redirects to account orders section with alert' do
        get '/espago/secure_web_page/payments/success', params: { order_number: 'invalid' }

        expect(response).to redirect_to("#{account_path}#orders")
        expect(flash[:alert]).to eq('We are experiencing an issue with your order')
      end
    end
  end

  describe 'GET /espago/secure_web_page/payments/failure' do
    context 'when the order exists' do
      it 'redirects to the order page with failure message' do
        get '/espago/secure_web_page/payments/failure', params: { order_number: order.order_number }

        expect(response).to redirect_to(order_path(order))
        expect(flash[:alert]).to eq('Payment failed!')
      end
    end

    context 'when the order does not exist' do
      it 'redirects to account orders section with alert' do
        get '/espago/secure_web_page/payments/failure', params: { order_number: 'invalid' }

        expect(response).to redirect_to("#{account_path}#orders")
        expect(flash[:alert]).to eq('We are experiencing an issue with your order')
      end
    end
  end
end
