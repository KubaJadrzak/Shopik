# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Espago::PaymentsController, type: :request do
  let(:user)       { create(:user) }

  describe 'when user is authenticated' do
    before do
      sign_in user
    end

    describe 'GET espago/payments/new' do

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


      context 'when no payable ID is provided' do
        it 'redirects to account_path with alert' do
          get espago_new_payment_path
          expect(response).to redirect_to(account_path)
          follow_redirect!
          expect(response.body).to include('We could not create your payment due to a technical issue')
        end
      end
    end
    describe 'POST espago/payments/charge' do
      let(:payable)     { create(:order, user: user) }
      let(:payment_number) { 'payment_number' }

      before do
        sign_in user
      end

      context 'when parent is not found' do
        it 'redirects to account_path with alert' do
          post espago_charge_path, params: {
            payable_type: 'Order',
            payable_id:   -1,
          }

          expect(response).to redirect_to(account_path)
          follow_redirect!
          expect(response.body).to include('We could not create your payment due to a technical issue')
        end
      end

      context 'when Espago returns a redirect_url' do
        it 'creates new payment and redirects to external payment URL' do
          allow_any_instance_of(Payment).to receive(:process_payment)
            .and_return([:redirect_url, 'https://payment.example.com'])

          expect do
            post espago_charge_path, params: {
              payable_type: 'Order',
              payable_id:   payable.id,
              payment_mode: 'new_one_time',
            }
          end.to change(Payment, :count).by(1)

          expect(Payment.last.state).to eq('new')
          expect(response).to redirect_to('https://payment.example.com')
        end
      end

      context 'when Espago returns :success' do
        it 'creates new payment and redirects to success path' do
          allow_any_instance_of(Payment).to receive(:process_payment)
            .and_return([:success, payment_number])

          expect do
            post espago_charge_path, params: {
              payable_type: 'Order',
              payable_id:   payable.id,
              payment_mode: 'new_one_time',
            }
          end.to change(Payment, :count).by(1)

          expect(Payment.last.state).to eq('new')
          expect(response).to redirect_to(espago_payments_success_path(payment_number))
        end
      end

      context 'when Espago returns :failure' do
        it 'creates new payment and redirects to failure path' do
          allow_any_instance_of(Payment).to receive(:process_payment)
            .and_return([:failure, payment_number])

          expect do
            post espago_charge_path, params: {
              payable_type: 'Order',
              payable_id:   payable.id,
              payment_mode: 'new_one_time',
            }
          end.to change(Payment, :count).by(1)

          expect(Payment.last.state).to eq('new')
          expect(response).to redirect_to(espago_payments_failure_path(payment_number))
        end
      end

      context 'when Espago returns :awaiting' do
        it 'creates new payment and redirects to awaiting path' do
          allow_any_instance_of(Payment).to receive(:process_payment)
            .and_return([:awaiting, payment_number])

          expect do
            post espago_charge_path, params: {
              payable_type: 'Order',
              payable_id:   payable.id,
              payment_mode: 'new_one_time',
            }
          end.to change(Payment, :count).by(1)

          expect(Payment.last.state).to eq('new')
          expect(response).to redirect_to(espago_payments_awaiting_path(payment_number))
        end
      end

    end
    describe 'GET espago/payments/payment_success' do
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

    describe 'GET espago/payments/payment_failure' do
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

    describe 'GET espago/payments/payment_awaiting' do
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

    describe 'POST espago/payments/reverse' do
      let(:order) { create(:order, user: user) }

      context 'when payment does not exist' do
        it 'redirects to account_path with alert' do
          post espago_reverse_payment_path(payment_number: 'nonexistent_payment_number')

          expect(response).to redirect_to(account_path)
          follow_redirect!
          expect(response.body).to include('We are experiencing an issue with your payment')
        end
      end

      context 'when payment exists but is not reversable' do
        let(:payment) { create(:payment, :for_order, :finalized, payable: order) }

        it 'redirects to account_path with alert' do
          post espago_reverse_payment_path(payment_number: payment.payment_number)

          expect(response).to redirect_to(account_path)
          follow_redirect!
          expect(response.body).to include('We are experiencing an issue with your payment')
        end
      end
    end


    describe 'POST espago/payments/refund' do
      let(:order) { create(:order, user: user) }

      context 'when payment does not exist' do
        it 'redirects to account_path with alert' do
          post espago_refund_payment_path(payment_number: 'nonexistent_payment_number')

          expect(response).to redirect_to(account_path)
          follow_redirect!
          expect(response.body).to include('We are experiencing an issue with your payment')
        end
      end

      context 'when payment exists but is not refundable' do
        let(:payment) { create(:payment, :for_order, :executed, payable: order) }

        it 'redirects to account_path with alert' do
          post espago_refund_payment_path(payment_number: payment.payment_number)

          expect(response).to redirect_to(account_path)
          follow_redirect!
          expect(response.body).to include('We are experiencing an issue with your payment')
        end
      end
    end



  end

end
