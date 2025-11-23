#frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :request do

  describe 'GET /account' do
    let(:user) { create(:user) }

    context 'when user is not signed in' do
      it 'redirects to the sign in page' do
        get account_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'when user is signed in' do
      before do
        @order = create(:order, user: user)
        @subscription = create(:subscription, user: user)
        @client = create(:client, user: user)
        @payment = create(:payment, :for_order, payable: @order, payment_id: 'PAY123')

        sign_in user
        get account_path
      end

      it 'redirects to account page' do
        expect(response).to have_http_status(:success)
      end
      it 'includes orders content in the response body when no section is provided' do
        expect(response.body).to include(@order.uuid)
      end
      it 'includes orders content in the response body when orders section is provided' do
        get account_path(section: 'orders')
        expect(response.body).to include(@order.uuid)
      end
      it 'includes subscription content in the response body when subscriptions section is provided' do
        get account_path(section: 'subscriptions')
        expect(response.body).to include(@subscription.uuid)
      end

      it 'includes clients (Payment Methods) content in the response body when clients section is provided' do
        get account_path(section: 'clients')
        expect(response.body).to include(@client.uuid)
      end

      it 'enqueues UpdatePaymentStatusJob on sign in' do
        ActiveJob::Base.queue_adapter = :test

        post user_session_path, params: { user: { email: user.email, password: user.password } }

        expect(Espago::UpdatePaymentStatusJob).to have_been_enqueued.with(user.id)
      end

      it 'enqueues UpdatePaymentStatusJob on account view visit' do
        ActiveJob::Base.queue_adapter = :test

        get account_path

        expect(Espago::UpdatePaymentStatusJob).to have_been_enqueued.with(user.id)
      end

      it 'UpdatePaymentStatusJob updates payment status' do
        allow_any_instance_of(Espago::Payment::StatusService)
          .to receive(:fetch_payment_status)
          .and_return('executed')

        perform_enqueued_jobs do
          Espago::UpdatePaymentStatusJob.perform_later(user.id)
        end

        expect(@order.reload.status).to eq('Preparing for Shipment')
        expect(@payment.reload.state).to eq('executed')
      end

      it 'triggers UpdatePaymentStatusJob and does not update the payment state when StatusService returns nil' do
        allow_any_instance_of(Espago::Payment::StatusService)
          .to receive(:fetch_payment_status)
          .and_return(nil)

        perform_enqueued_jobs do
          Espago::UpdatePaymentStatusJob.perform_later(user.id)
        end

        expect(@order.reload.status).to eq('New')
        expect(@payment.reload.state).to eq('new')
      end
    end
  end
end
