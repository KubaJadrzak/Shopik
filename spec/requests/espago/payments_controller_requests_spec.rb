require 'rails_helper'

RSpec.describe 'Espago::Payments', type: :request do
  let(:user)       { create(:user) }

  describe 'when user is authenticated' do
    before do
      sign_in user
    end

    describe 'GET /payments/new' do
      let(:espago_public_key) { 'test_public_key' }

      before do
        allow(ENV).to receive(:fetch).with('ESPAGO_PUBLIC_KEY', nil).and_return(espago_public_key)
      end

      context 'when order_id is provided' do
        let(:order) { create(:order) }

        it 'returns http success' do
          get espago_new_payment_path(order_id: order.id)
          expect(response).to have_http_status(:success)
        end
      end

      context 'when subscription_id is provided' do
        let(:subscription) { create(:subscription) }

        it 'returns http success' do
          get espago_new_payment_path(subscription_id: subscription.id)
          expect(response).to have_http_status(:success)
        end
      end

      context 'when client_id is provided' do
        let(:client) { create(:client) }

        it 'returns http success' do
          get espago_new_payment_path(client_id: client.id)
          expect(response).to have_http_status(:success)
        end
      end

      context 'when no parent ID is provided' do
        it 'redirects to root_path with alert' do
          get espago_new_payment_path
          expect(response).to redirect_to(root_path)
          follow_redirect!
          expect(response.body).to include('Missing parent to create payment.')
        end
      end
    end
    describe 'POST #start_payment' do
      let(:parent)     { create(:order, user: user) }

      before do
        sign_in user
      end

      context 'when parent is not found' do
        it 'redirects to account_path with alert' do
          post espago_start_payment_path, params: {
            parent_type: 'Order',
            parent_id:   -1,
          }

          expect(response).to redirect_to(account_path)
          follow_redirect!
          expect(response.body).to include('We could not create your payment due to a technical issue')
        end
      end

      context 'when Espago returns a redirect_url' do
        before do
          allow(Espago::Payment::PaymentInitializer).to receive(:initilize).and_return('fake_response')
          allow(Espago::Payment::PaymentResponseHandler).to receive(:handle_response)
            .with(instance_of(Payment), 'fake_response')
            .and_return([:redirect_url, 'https://payment.example.com'])
        end

        it 'redirects to external payment URL' do
          post espago_start_payment_path, params: {
            parent_type: 'Order',
            parent_id:   parent.id,
          }

          expect(response).to redirect_to('https://payment.example.com')
        end
      end

      context 'when Espago returns :success' do
        let(:payment_number) { 'pay_1234' }

        before do
          allow(Espago::Payment::PaymentInitializer).to receive(:initilize).and_return('fake_response')
          allow(Espago::Payment::PaymentResponseHandler).to receive(:handle_response)
            .with(instance_of(Payment), 'fake_response')
            .and_return([:success, payment_number])
        end

        it 'redirects to success path' do
          post espago_start_payment_path, params: {
            parent_type: 'Order',
            parent_id:   parent.id,
          }

          expect(response).to redirect_to(espago_payments_success_path(payment_number))
        end
      end

      context 'when Espago returns :failure' do
        let(:payment_number) { 'pay_1234' }

        before do
          allow(Espago::Payment::PaymentInitializer).to receive(:initilize).and_return('fake_response')
          allow(Espago::Payment::PaymentResponseHandler).to receive(:handle_response)
            .with(instance_of(Payment), 'fake_response')
            .and_return([:failure, payment_number])
        end

        it 'redirects to failure path' do
          post espago_start_payment_path, params: {
            parent_type: 'Order',
            parent_id:   parent.id,
          }

          expect(response).to redirect_to(espago_payments_failure_path(payment_number))
        end
      end

      context 'when Espago returns :awaiting' do
        let(:payment_number) { 'pay_1234' }

        before do
          allow(Espago::Payment::PaymentInitializer).to receive(:initilize).and_return('fake_response')
          allow(Espago::Payment::PaymentResponseHandler).to receive(:handle_response)
            .with(instance_of(Payment), 'fake_response')
            .and_return([:awaiting, payment_number])
        end

        it 'redirects to awaiting path' do
          post espago_start_payment_path, params: {
            parent_type: 'Order',
            parent_id:   parent.id,
          }

          expect(response).to redirect_to(espago_payments_awaiting_path(payment_number))
        end
      end
    end
    describe 'GET #payment_success' do
      context 'when payment does not exist' do
        it 'redirects to account_path with alert' do
          get espago_payments_success_path('nonexistent_payment_number')

          expect(response).to redirect_to(account_path)
          follow_redirect!
          expect(response.body).to include('We are experiencing an issue with your payment')
        end
      end

      context 'when payment is for an Order' do
        let(:order) { create(:order, user: user) }
        let(:payment) { create(:payment, payable: order) }

        it 'redirects to order_path with success notice' do
          get espago_payments_success_path(payment.payment_number)

          expect(response).to redirect_to(order_path(order))
          follow_redirect!
          expect(response.body).to include('Payment successful!')
        end
      end

      context 'when payment is for a Subscription' do
        let(:subscription) { create(:subscription, user: user) }
        let(:payment) { create(:payment, payable: subscription) }

        it 'redirects to subscription_path with success notice' do
          get espago_payments_success_path(payment.payment_number)

          expect(response).to redirect_to(subscription_path(subscription))
          follow_redirect!
          expect(response.body).to include('Payment successful!')
        end
      end

      context 'when payment is for a Client' do
        let(:client) { create(:client) }
        let(:payment) { create(:payment, payable: client) }

        it 'redirects to espago_client_path with success notice' do
          get espago_payments_success_path(payment.payment_number)

          expect(response).to redirect_to(espago_client_path(client))
          follow_redirect!
          expect(response.body).to include('Payment successful!')
        end
      end
    end

    describe 'GET #payment_failure' do
      context 'when payment does not exist' do
        it 'redirects to account_path with alert' do
          get espago_payments_failure_path('nonexistent_payment_number')

          expect(response).to redirect_to(account_path)
          follow_redirect!
          expect(response.body).to include('We are experiencing an issue with your payment')
        end
      end

      context 'when payment is for an Order' do
        let(:order) { create(:order, user: user) }
        let(:payment) { create(:payment, payable: order) }

        it 'redirects to order_path with failure notice' do
          get espago_payments_failure_path(payment.payment_number)

          expect(response).to redirect_to(order_path(order))
          follow_redirect!
          expect(response.body).to include('Payment failed!')
        end
      end

      context 'when payment is for a Subscription' do
        let(:subscription) { create(:subscription, user: user) }
        let(:payment) { create(:payment, payable: subscription) }

        it 'redirects to subscription_path with failure notice' do
          get espago_payments_failure_path(payment.payment_number)

          expect(response).to redirect_to(subscription_path(subscription))
          follow_redirect!
          expect(response.body).to include('Payment failed!')
        end
      end

      context 'when payment is for a Client' do
        let(:client) { create(:client) }
        let(:payment) { create(:payment, payable: client) }

        it 'redirects to espago_client_path with failure notice' do
          get espago_payments_failure_path(payment.payment_number)

          expect(response).to redirect_to(espago_client_path(client))
          follow_redirect!
          expect(response.body).to include('Payment failed!')
        end
      end
    end

    describe 'GET #payment_awaiting' do
      context 'when payment does not exist' do
        it 'redirects to account_path with alert' do
          get espago_payments_awaiting_path('nonexistent_payment_number')

          expect(response).to redirect_to(account_path)
          follow_redirect!
          expect(response.body).to include('We are experiencing an issue with your payment')
        end
      end

      context 'when payment is for an Order' do
        let(:order) { create(:order, user: user) }
        let(:payment) { create(:payment, payable: order) }

        it 'redirects to order_path with processing notice' do
          get espago_payments_awaiting_path(payment.payment_number)

          expect(response).to redirect_to(order_path(order))
          follow_redirect!
          expect(response.body).to include('Payment is being processed!')
        end
      end

      context 'when payment is for a Subscription' do
        let(:subscription) { create(:subscription, user: user) }
        let(:payment) { create(:payment, payable: subscription) }

        it 'redirects to subscription_path with processing notice' do
          get espago_payments_awaiting_path(payment.payment_number)

          expect(response).to redirect_to(subscription_path(subscription))
          follow_redirect!
          expect(response.body).to include('Payment is being processed!')
        end
      end

      context 'when payment is for a Client' do
        let(:client) { create(:client) }
        let(:payment) { create(:payment, payable: client) }

        it 'redirects to espago_client_path with processing notice' do
          get espago_payments_awaiting_path(payment.payment_number)

          expect(response).to redirect_to(espago_client_path(client))
          follow_redirect!
          expect(response.body).to include('Payment is being processed!')
        end
      end
    end
  end

end
