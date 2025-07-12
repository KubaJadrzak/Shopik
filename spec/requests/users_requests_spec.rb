require 'rails_helper'

RSpec.describe 'UsersController Requests Test', type: :request do

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
        @root_rubits = create_list(:rubit, 3, user: user)

        parent_rubit = create(:rubit, user: user)
        @child_rubits = create_list(:rubit, 2, user: user, parent_rubit: parent_rubit)

        liked_rubit = create(:rubit, content: 'this is liked Rubit')
        create(:like, user: user, rubit: liked_rubit)

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

      it 'includes root rubits content in the response body' do
        @root_rubits.each do |rubit|
          expect(response.body).to include(rubit.content)
        end
      end

      it 'includes liked rubits content in the response body' do
        expect(response.body).to include('this is liked Rubit')
      end

      it 'includes child rubits (comments) content in the response body' do
        @child_rubits.each do |rubit|
          expect(response.body).to include(rubit.content)
        end
      end
      it 'includes orders content in the response body' do
        expect(response.body).to include(@order.order_number)
      end
      it 'includes subscription content in the response body' do
        expect(response.body).to include(@subscription.subscription_number)
      end

      it 'includes clients (Payment Methods) content in the response body' do
        expect(response.body).to include(@client.client_number)
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
        allow_any_instance_of(Espago::StatusService)
          .to receive(:fetch_payment_status)
          .and_return('executed')

        perform_enqueued_jobs do
          Espago::UpdatePaymentStatusJob.perform_later(user.id)
        end

        expect(@order.reload.status).to eq('Preparing for Shipment')
        expect(@payment.reload.state).to eq('executed')
      end

      it 'triggers UpdatePaymentStatusJob and does not update the payment status when StatusService returns nil' do
        allow_any_instance_of(Espago::StatusService)
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
