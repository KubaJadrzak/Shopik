require 'rails_helper'

RSpec.describe Subscription, type: :model do
  describe 'callbacks' do
    let(:subscription) { create(:subscription, start_date: nil, end_date: nil, price: nil) }

    it 'sets default start and end dates on create if none is given' do
      expect(subscription.start_date).to eq(Date.today)
      expect(subscription.end_date).to eq(30.days.from_now.to_date)
    end

    it 'sets a default price on create if none is given' do
      expect(subscription.price).to eq(BigDecimal('4.99'))
    end

    it 'generates a subscription number' do
      expect(subscription.subscription_number).to be_present
      expect(subscription.subscription_number.length).to eq(20) # 10 bytes in hex = 20 chars
    end
  end
  describe 'methods' do

    describe '#in_progress_payment' do
      let(:subscription) { create(:subscription) }
      let!(:failed_payment) { create(:payment, subscription: subscription, state: 'failed') }
      let!(:in_progress_payment) { create(:payment, subscription: subscription, state: 'new') }

      before do
        allow(subscription.payments).to receive(:in_progress).and_return([in_progress_payment])
      end

      it 'returns the first in-progress payment' do
        expect(subscription.in_progress_payment).to eq(in_progress_payment)
      end
    end

    describe '#in_progress_payment?' do
      let(:subscription) { create(:subscription) }

      context 'when in-progress payment is present' do
        before { allow(subscription).to receive(:in_progress_payment).and_return(double(Payment)) }

        it { expect(subscription.in_progress_payment?).to be(true) }
      end

      context 'when no in-progress payment' do
        before { allow(subscription).to receive(:in_progress_payment).and_return(nil) }

        it { expect(subscription.in_progress_payment?).to be(false) }
      end
    end

    describe '#can_retry_payment?' do
      let(:subscription) { create(:subscription) }

      context 'when all payments are retryable' do
        let(:retryable_payments) do
          [instance_double(Payment, retryable?: true), instance_double(Payment, retryable?: true)]
        end

        before { allow(subscription).to receive(:payments).and_return(retryable_payments) }

        it { expect(subscription.can_retry_payment?).to be(true) }
      end

      context 'when at least one payment is not retryable' do
        let(:mixed_payments) do
          [instance_double(Payment, retryable?: true), instance_double(Payment, retryable?: false)]
        end

        before { allow(subscription).to receive(:payments).and_return(mixed_payments) }

        it { expect(subscription.can_retry_payment?).to be(false) }
      end

      context 'when there are no payments' do
        before { allow(subscription).to receive(:payments).and_return([]) }

        it { expect(subscription.can_retry_payment?).to be(true) }
      end
    end
  end
end
