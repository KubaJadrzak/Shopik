#frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubscriptionsController, type: :request do
  let(:user) { create(:user) }

  describe 'when user is authorized' do
    before do
      sign_in user
    end
    describe 'GET subscription/new' do
      it 'returns http success' do
        get new_subscription_path
        expect(response).to have_http_status(:success)
      end
    end

    describe 'GET subscription/:id' do
      let(:subscription) { create(:subscription) }
      it 'return http success' do
        get subscription_path(subscription)
        expect(response).to have_http_status(:success)
      end
    end

    describe 'POST /subscriptions/:id/toggle_auto_renew' do
      context 'when subscription is inactive' do
        let(:subscription) { create(:subscription, user: user, status: 'Expired') }

        it 'redirects to subscriptions with alert' do
          patch toggle_auto_renew_subscription_path(subscription)

          expect(response).to redirect_to("#{account_path}#subscriptions")
          follow_redirect!
          expect(response.body).to include('This subscription is not active')
        end
      end

      context 'when user has no primary payment method' do
        let(:subscription) { create(:subscription, user: user, status: 'Active') }
        it 'redirects with missing payment method alert' do
          patch toggle_auto_renew_subscription_path(subscription)

          expect(response).to redirect_to("#{account_path}#subscriptions")
          follow_redirect!
          expect(response.body).to include('Cannot enable auto-renew without primary payment method')
        end
      end

      context 'when subscription is active and user has primary payment method' do
        let!(:client) { create(:client, :primary, user: user) }
        let(:subscription) { create(:subscription, user: user, status: 'Active') }


        it 'toggles auto_renew and redirects' do
          expect do
            patch toggle_auto_renew_subscription_path(subscription)
          end.to change { subscription.reload.auto_renew }
            .from(false).to(true)
        end
      end
    end

    describe 'POST /subscriptions' do
      context 'when user has an active subscription' do
        let!(:subscription) { create(:subscription, user: user, status: 'Active') }
        it 'redirects with alert' do
          post subscriptions_path

          expect(response).to redirect_to("#{account_path}#subscriptions")
          follow_redirect!
          expect(response.body).to include('You already have an active subscription.')
        end
      end

      context 'when user has a pending subscription' do
        let!(:subscription) do
          create(:subscription, user: user, start_date: nil, end_date: nil, status: 'Awaiting Payment')
        end

        it 'redirects with pending alert' do
          post subscriptions_path

          expect(response).to redirect_to("#{account_path}#subscriptions")
          follow_redirect!
          expect(response.body).to include('You already have a pending subscription.')
        end
      end

      context 'when subscription is created successfully' do

        it 'creates a subscription and redirects to payment path' do
          expect do
            post subscriptions_path
          end.to change(Subscription, :count).by(1)

          new_subscription = Subscription.last
          expect(response).to redirect_to(espago_new_payment_path(subscription_id: new_subscription.id))
        end
      end
    end
  end
end
