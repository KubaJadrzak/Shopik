require 'rails_helper'

RSpec.describe Payment, type: :model do

  describe 'validations' do
    it 'is invalid without a subscription or order' do
      payment = build(:payment, subscription: nil, order: nil)
      expect(payment).not_to be_valid
      expect(payment.errors[:base]).to include('Payment must belong to either a subscription or an order')
    end

    describe '#prevent_duplicate_payment' do
      let(:subscription) { create(:subscription) }
      let(:order) { create(:order) }
      context 'for subscription payments' do
        before do
          create(:payment, subscription: subscription, state: 'new')
        end

        it 'prevents creating a new payment if one in progress exists' do
          new_payment = build(:payment, subscription: subscription, state: 'new')
          expect(new_payment.save).to be false
          expect(new_payment.errors[:base]).to include(
            'Cannot create new payment: subscription already has a payment in progress or successful',
          )
        end

        it 'allows updating the existing payment' do
          payment = subscription.payments.first
          payment.state = 'executed'
          expect(payment.save).to be true
        end

        it 'allows creating a payment for a different subscription' do
          other_subscription = create(:subscription)
          new_payment = build(:payment, subscription: other_subscription, state: 'new')
          expect(new_payment.save).to be true
        end
      end

      context 'for order payments' do
        before do
          create(:payment, order: order, state: 'new')
        end

        it 'prevents creating a new payment if one in progress exists' do
          new_payment = build(:payment, order: order, state: 'new')
          expect(new_payment.save).to be false
          expect(new_payment.errors[:base]).to include(
            'Cannot create new payment: order already has a payment in progress or successful',
          )
        end

        it 'allows updating the existing payment' do
          payment = order.payments.first
          payment.state = 'executed'
          expect(payment.save).to be true
        end

        it 'allows creating a payment for a different order' do
          other_order = create(:order)
          new_payment = build(:payment, order: other_order, state: 'new')
          expect(new_payment.save).to be true
        end
      end

      context 'when payment has neither subscription nor order' do
        it 'is invalid' do
          payment = build(:payment, subscription: nil, order: nil)
          expect(payment).not_to be_valid
          expect(payment.errors[:base]).to include('Payment must belong to either a subscription or an order')
        end
      end
    end
  end

  describe 'callbacks' do
    it 'generates a payment number before creation' do
      payment = create(:payment, :for_order)
      expect(payment.payment_number).to be_present
    end
  end
  describe 'methods' do
    describe '#in_progress' do
      it 'returns only payments with in-progress statuses' do
        in_progress_payment = create(:payment, :for_order, state: 'new')
        create(:payment, :for_order, state: 'executed')

        expect(Payment.in_progress).to include(in_progress_payment)
        expect(Payment.in_progress.pluck(:state)).to all(satisfy { |s| Payment::IN_PROGRESS_STATUSES.include?(s) })
      end
    end

    describe '#in_progress?' do
      it 'returns true if payment state is in-progress' do
        payment = build(:payment, state: 'tds_redirected')
        expect(payment.in_progress?).to be true
      end

      it 'returns false if payment state is not in-progress' do
        payment = build(:payment, state: 'executed')
        expect(payment.in_progress?).to be false
      end
    end

    describe '#successful?' do
      it 'returns true if payment state is executed' do
        payment = build(:payment, state: 'executed')
        expect(payment.successful?).to be true
      end

      it 'returns false if payment state is not executed' do
        payment = build(:payment, state: 'new')
        expect(payment.successful?).to be false
      end
    end

    describe '#retryable?' do
      it 'returns false if payment is in progress' do
        payment = build(:payment, state: 'new')
        expect(payment.retryable?).to be false
      end

      it 'returns false if payment is successful' do
        payment = build(:payment, state: 'executed')
        expect(payment.retryable?).to be false
      end

      it 'returns true for failed/rejected payment' do
        payment = build(:payment, state: 'failed')
        expect(payment.retryable?).to be true
      end
    end

    describe '#show_status_by_payment_status' do
      it 'returns status of associated order/subscription based on payment state' do
        payment = build(:payment)
        expect(payment.show_status_by_payment_status('executed')).to eq('Payment Successful')
      end
    end

    describe '#update_status_by_payment_status' do
      let(:subscription) { create(:subscription) }
      let(:order)        { create(:order) }

      it 'updates state and associated subscription status' do
        payment = create(:payment, :for_subscription, subscription: subscription)
        payment.update_status_by_payment_status('executed')

        expect(payment.state).to eq('executed')
        expect(subscription.reload.status).to eq('Payment Successful')
      end

      it 'updates state and associated order status' do
        payment = create(:payment, :for_order, order: order)
        payment.update_status_by_payment_status('failed')

        expect(payment.state).to eq('failed')
        expect(order.reload.status).to eq('Payment Failed')
      end
    end
  end
end
