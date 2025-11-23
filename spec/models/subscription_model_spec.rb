#frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subscription, type: :model do
  describe 'callbacks' do
    it 'generate_uuid' do
      subscription = create(:subscription)
      expect(subscription.uuid).to be_present
      expect(subscription.uuid.length).to eq(20)
    end
  end

  describe 'validations' do
    context 'auto_renew_requires_primary_payment_method' do
      it 'prevent enabling of auto renew without primary payment method' do
        user = create(:user)
        subscription = create(:subscription, user: user)

        expect(subscription.update(auto_renew: true)).to be false
        expect(subscription.errors[:base]).to include(
          "Cannot enable auto-renew for this subscription: user doesn't have primary payment method",
        )
      end
    end
  end

  describe 'scopes' do
    describe 'should_be_expired' do
      it 'includes active subscriptions with end_date in the past' do
        expired = create(:subscription, status: 'Active', end_date: 1.day.ago)
        not_expired = create(:subscription, status: 'Active', end_date: 1.day.from_now)

        expect(Subscription.should_be_expired).to include(expired)
        expect(Subscription.should_be_expired).not_to include(not_expired)
      end
    end

    describe 'should_be_renewed' do
      it 'includes active subscriptions with enabled auto_renew and tomorrow expiration date' do
        user = create(:user)
        create(:client, :primary, user: user)
        renewed = create(:subscription, user: user, status: 'Active', auto_renew: true, end_date: Date.current + 1.day)
        not_renewed = create(:subscription, user: user,  status: 'Active', auto_renew: true,
end_date: Date.current + 2.days,)

        expect(Subscription.should_be_renewed).to include(renewed)
        expect(Subscription.should_be_renewed).not_to include(not_renewed)
      end
    end
  end

  describe 'methods' do
    describe 'can_retry_payment?' do
      let(:subscription) { create(:subscription) }

      context 'when all payments are retryable' do
        it 'returns true when all payments are retryable' do
          create(:payment, :for_subscription, payable: subscription, state: 'failed')
          create(:payment, :for_subscription, payable: subscription, state: 'failed')

          expect(subscription.reload.can_retry_payment?).to be(true)
        end
      end

      context 'when at least one payment is not retryable' do
        it 'returns false when at least one payment is not retryable' do
          create(:payment, :for_subscription, payable: subscription, state: 'failed')
          create(:payment, :for_subscription, payable: subscription, state: 'new')

          expect(subscription.reload.can_retry_payment?).to be(false)
        end
      end

      context 'when there are no payments' do
        it 'returns true when there are no payments' do
          expect(subscription.can_retry_payment?).to be(true)
        end
      end
    end

    describe 'can_extend_subscription?' do
      let(:subscription) { create(:subscription) }

      context 'when subscription is active and has no awaiting payments' do

        it 'returns true' do
          create(:payment, :for_subscription, payable: subscription, state: 'failed')

          expect(subscription.can_extend_subscription?).to be(true)
        end
      end

      context 'when subscription is active but has an awaiting payment' do

        it 'returns false' do
          create(:payment, :for_subscription, payable: subscription, state: 'new')

          expect(subscription.can_extend_subscription?).to be(false)
        end
      end

      context 'when subscription is expired' do
        it 'returns false' do
          expired_subscription = create(:subscription, start_date: nil, end_date: nil, status: 'expired')

          expect(expired_subscription.can_extend_subscription?).to be(false)
        end

      end
    end

    describe 'extension_payment_failed?' do
      let(:subscription) { create(:subscription) }

      context 'when the latest payment simplified_state is failure' do
        it 'returns true' do
          create(:payment, :for_subscription, payable: subscription, state: 'failed')

          expect(subscription.extension_payment_failed?).to be(true)
        end
      end

      context 'when the latest payment simplified_state is not failure' do
        it 'returns false' do
          create(:payment, :for_subscription, payable: subscription, state: 'executed')

          expect(subscription.extension_payment_failed?).to be(false)
        end
      end

      context 'when there are no payments' do
        it 'returns false' do
          expect(subscription.extension_payment_failed?).to be(false)
        end
      end
    end

    describe 'extend_or_initialize_dates!' do
      let(:subscription) { create(:subscription) }

      context 'when start_date and end_date are nil' do
        it 'sets start_date to today and end_date to 30 days from now' do
          subscription.update!(start_date: nil, end_date: nil)
          subscription.extend_or_initialize_dates!

          expect(subscription.start_date).to eq(Date.today)
          expect(subscription.end_date).to eq(30.days.from_now.to_date)
        end
      end

      context 'when start_date and end_date are present' do
        it 'extends the end_date by 30 days' do
          subscription.update!(start_date: 10.days.ago.to_date, end_date: Date.today)
          subscription.extend_or_initialize_dates!

          expect(subscription.end_date).to eq(Date.today + 30.days)
        end
      end
    end

    describe 'renew' do
      context 'when user has primary payment method' do
        it 'extends subscription end date by 30 days' do
          user = create(:user)
          create(:client, :real, user: user, status: 'MIT', primary: true)
          subscription = create(:subscription, auto_renew: true,  user: user)
          subscription.renew
          subscription.reload

          expect(subscription.end_date).to eq(60.days.from_now.to_date)
        end
      end
    end



    describe 'amount' do
      it 'returns the price' do
        subscription = create(:subscription, price: 99.99)

        expect(subscription.amount).to eq(99.99)
      end
    end
  end
end
