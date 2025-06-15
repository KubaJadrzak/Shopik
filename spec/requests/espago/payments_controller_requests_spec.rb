require 'rails_helper'

RSpec.describe 'Espago::Payments', type: :request do
  let(:user) { create(:user) }
  let(:card_token) { 'cc_1234' }


  describe 'when user is authenticated' do
    before do
      sign_in user
    end
    describe 'GET /espago/payments/:payment_number/start_payment' do
      let(:order) { create(:order) }
      let(:payment) { create(:payment, :for_order, order: order) }

      context 'when payment is not found' do
        it 'redirects to account path with alert message' do
          get '/espago/payments/INVALID/start_payment'
          expect(response).to redirect_to(account_path)
          follow_redirect!
          expect(flash[:alert]).to eq('We could not process your payment due to a technical issue')
        end
      end

      context 'when payment is found' do
        context 'when response action is redirect_url' do
          let(:action) { :redirect_url }
          let(:param) { 'https://external-payment.com/gateway' }

          it 'redirects to external payment URL' do

            allow(Payment).to receive(:find_by).with(payment_number: payment.payment_number).and_return(payment)
            allow_any_instance_of(Espago::PaymentsController).to receive(:session).and_return(
              double('session', delete: card_token),
            )
            allow(Espago::Payment::PaymentInitializer).to receive(:process).and_return('response')
            allow(Espago::Payment::PaymentResponseHandler).to receive(:handle_response).and_return([action, param])

            get "/espago/payments/#{payment.payment_number}/start_payment"

            expect(response).to redirect_to(param)
          end
        end

        context 'when response action is success' do
          let(:action) { :success }
          let(:param) { payment.payment_number }

          it 'redirects to success path' do

            allow(Payment).to receive(:find_by).with(payment_number: payment.payment_number).and_return(payment)
            allow_any_instance_of(Espago::PaymentsController).to receive(:session).and_return(
              double('session', delete: card_token),
            )
            allow(Espago::Payment::PaymentInitializer).to receive(:process).and_return('response')
            allow(Espago::Payment::PaymentResponseHandler).to receive(:handle_response).and_return([action, param])

            get "/espago/payments/#{payment.payment_number}/start_payment"

            expect(response).to redirect_to(espago_payments_success_path(param))
          end
        end

        context 'when response action is awaiting' do
          let(:action) { :awaiting }
          let(:param) { payment.payment_number }

          it 'redirects to awaiting path' do

            allow(Payment).to receive(:find_by).with(payment_number: payment.payment_number).and_return(payment)
            allow_any_instance_of(Espago::PaymentsController).to receive(:session).and_return(
              double('session', delete: card_token),
            )
            allow(Espago::Payment::PaymentInitializer).to receive(:process).and_return('response')
            allow(Espago::Payment::PaymentResponseHandler).to receive(:handle_response).and_return([action, param])

            get "/espago/payments/#{payment.payment_number}/start_payment"

            expect(response).to redirect_to(espago_payments_awaiting_path(param))
          end
        end

        context 'when response action is failure' do
          let(:action) { :failure }
          let(:param) { payment.payment_number }


          it 'redirects to failure path' do

            allow(Payment).to receive(:find_by).with(payment_number: payment.payment_number).and_return(payment)
            allow_any_instance_of(Espago::PaymentsController).to receive(:session).and_return(
              double('session', delete: card_token),
            )
            allow(Espago::Payment::PaymentInitializer).to receive(:process).and_return('response')
            allow(Espago::Payment::PaymentResponseHandler).to receive(:handle_response).and_return([action, param])

            get "/espago/payments/#{payment.payment_number}/start_payment"

            expect(response).to redirect_to(espago_payments_failure_path(param))
          end
        end
      end
    end

    describe 'GET /espago/payments/:payment_number/success' do
      context 'when payment is not found' do
        it 'redirects to account path with error message' do
          get '/espago/payments/INVALID/success'
          expect(response).to redirect_to(account_path)
          follow_redirect!
          expect(flash[:alert]).to eq('We are experiencing an issue with your payment')
        end
      end

      context 'when payment has a subscription' do
        let(:subscription) { create(:subscription) }
        let(:payment) { create(:payment, :for_subscription, subscription: subscription) }

        before do
          allow(Payment).to receive(:find_by).with(payment_number: payment.payment_number).and_return(payment)
        end

        it 'redirects to subscription path with success notice' do
          get "/espago/payments/#{payment.payment_number}/success"
          expect(response).to redirect_to(subscription_path(subscription))
          follow_redirect!
          expect(flash[:notice]).to eq('Payment successful!')
        end
      end

      context 'when payment has an order' do
        let(:order) { create(:order) }
        let(:payment) { create(:payment, :for_order, order: order) }

        before do
          allow(Payment).to receive(:find_by).with(payment_number: payment.payment_number).and_return(payment)
        end

        it 'redirects to order path with success notice' do
          get "/espago/payments/#{payment.payment_number}/success"
          expect(response).to redirect_to(order_path(order))
          follow_redirect!
          expect(flash[:notice]).to eq('Payment successful!')
        end
      end
    end

    describe 'GET /espago/payments/:payment_number/failure' do
      context 'when payment is not found' do
        it 'redirects to account path with error message' do
          get '/espago/payments/INVALID/failure'

          expect(response).to redirect_to(account_path)
          follow_redirect!
          expect(flash[:alert]).to eq('We are experiencing an issue with your payment')
        end
      end

      context 'when payment has a subscription' do
        let(:subscription) { create(:subscription) } # Defined subscription
        let(:payment) { create(:payment, :for_subscription, subscription: subscription) }

        before do
          allow(Payment).to receive(:find_by).with(payment_number: payment.payment_number).and_return(payment)
        end

        it 'redirects to subscription path with failure notice' do
          get "/espago/payments/#{payment.payment_number}/failure"

          expect(response).to redirect_to(subscription_path(subscription))
          follow_redirect!
          expect(flash[:notice]).to eq('Payment failed!')
        end
      end

      context 'when payment has an order' do
        let(:order) { create(:order) } # Defined order
        let(:payment) { create(:payment, :for_order, order: order) }

        before do
          allow(Payment).to receive(:find_by).with(payment_number: payment.payment_number).and_return(payment)
        end

        it 'redirects to order path with failure notice' do
          get "/espago/payments/#{payment.payment_number}/failure"

          expect(response).to redirect_to(order_path(order))
          follow_redirect!
          expect(flash[:notice]).to eq('Payment failed!')
        end
      end

    end

    describe 'GET /espago/payments/:payment_number/awaiting' do
      context 'when payment is not found' do
        it 'redirects to account path with error message' do
          get '/espago/payments/INVALID/awaiting'

          expect(response).to redirect_to(account_path)
          follow_redirect!
          expect(flash[:alert]).to eq('We are experiencing an issue with your payment')
        end
      end

      context 'when payment has a subscription' do
        let(:subscription) { create(:subscription) } # Defined subscription
        let(:payment) { create(:payment, :for_subscription, subscription: subscription) }

        before do
          allow(Payment).to receive(:find_by).with(payment_number: payment.payment_number).and_return(payment)
        end

        it 'redirects to subscription path with processing notice' do
          get "/espago/payments/#{payment.payment_number}/awaiting"

          expect(response).to redirect_to(subscription_path(subscription))
          follow_redirect!
          expect(flash[:notice]).to eq('Payment is being processed!')
        end
      end

      context 'when payment has an order' do
        let(:order) { create(:order) }
        let(:payment) { create(:payment, :for_order, order: order) }

        before do
          allow(Payment).to receive(:find_by).with(payment_number: payment.payment_number).and_return(payment)
        end

        it 'redirects to order path with processing notice' do
          get "/espago/payments/#{payment.payment_number}/awaiting"

          expect(response).to redirect_to(order_path(order))
          follow_redirect!
          expect(flash[:notice]).to eq('Payment is being processed!')
        end
      end
    end
  end
  describe 'when user is not authenticated' do

    it 'redirects to the sign in page for /start_payment' do
      get '/espago/payments/123/start_payment'
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'redirects to the sign in page for /success' do
      get '/espago/payments/123/success'
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'redirects to the sign in page for /failure' do
      get '/espago/payments/123/failure'
      expect(response).to redirect_to(new_user_session_path)
    end

    it 'redirects to the sign in page for /awaiting' do
      get '/espago/payments/123/awaiting'
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
