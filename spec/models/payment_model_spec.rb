# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Payment, type: :model do

  describe 'validations' do
    context 'must_have_payable' do
      it 'is invalid without payable (subscription, order or client)' do
        payment = build(:payment, payable: nil)
        expect(payment).not_to be_valid
        expect(payment.errors[:base]).to include('Payment must belong to a payable entity')
      end
    end

    context 'prevent_duplicate_payment_for_subscription' do
      let(:subscription) { create(:subscription) }
      it 'prevents creating a new payment if one awaiting exists' do
        create(:payment, :for_subscription, payable: subscription, state: 'new')
        new_payment = build(:payment, payable: subscription, state: 'new')
        expect(new_payment.save).to be false
        expect(new_payment.errors[:base]).to include(
          'Cannot create new payment: subscription already has a pending or uncertain payment',
        )
      end

      it 'allows to create a new payment if one successful exists' do
        create(:payment, :for_subscription, payable: subscription, state: 'executed')
        new_payment = build(:payment, payable: subscription, state: 'new')
        expect(new_payment.save).to be true
      end

      it 'allows updating the existing payment' do
        payment = create(:payment, :for_subscription, payable: subscription, state: 'new')
        payment.state = 'executed'
        expect(payment.save).to be true
      end

      it 'allows creating a payment for a different subscription' do
        create(:payment, :for_subscription, payable: subscription, state: 'new')
        other_subscription = create(:subscription)
        new_payment = build(:payment, :for_subscription, payable: other_subscription, state: 'new')
        expect(new_payment.save).to be true
      end
    end
    context 'prevent_duplicate_payment_for_orders' do
      let(:order) { create(:order) }

      it 'prevents creating a new payment if one awaiting exists' do
        create(:payment, :for_order, payable: order, state: 'new')
        new_payment = build(:payment, :for_order, payable: order, state: 'new')
        expect(new_payment.save).to be false
        expect(new_payment.errors[:base]).to include(
          'Cannot create new payment: order already has a payment awaiting or successful',
        )
      end

      it 'prevents creating a new payment if one successful exists' do
        create(:payment, :for_order, payable: order, state: 'executed')
        new_payment = build(:payment, :for_order, payable: order, state: 'new')
        expect(new_payment.save).to be false
        expect(new_payment.errors[:base]).to include(
          'Cannot create new payment: order already has a payment awaiting or successful',
        )
      end

      it 'allows updating the existing payment' do
        payment = create(:payment, :for_order, payable: order, state: 'new')
        payment.state = 'executed'
        expect(payment.save).to be true
      end

      it 'allows creating a payment for a different order' do
        create(:payment, :for_order, payable: order, state: 'new')
        other_order = create(:order)
        new_payment = build(:payment, :for_order, payable: other_order, state: 'new')
        expect(new_payment.save).to be true
      end
    end

    context 'prevent_duplicate_payable_payment_for_clients' do
      let(:client) { create(:client) }

      it 'prevents creating a new payable payment if one awaiting exists' do
        create(:payment, :for_client, payable: client, state: 'new')
        new_payment = build(:payment, :for_client, payable: client, state: 'new')
        expect(new_payment.save).to be false
        expect(new_payment.errors[:base]).to include(
          'Cannot create new payment: client already has an awaiting payable payment',
        )
      end

      it 'allows updating the existing payment' do
        payment = create(:payment, :for_client, payable: client, state: 'new')
        payment.state = 'executed'
        expect(payment.save).to be true
      end
    end
  end

  describe 'callbacks' do
    it 'generates a payment number before creation' do
      payment = create(:payment, :for_order)
      expect(payment.payment_number).to be_present
    end
  end

  describe 'scopes' do
    describe 'successful' do
      it 'includes payments with successful states' do
        payment = create(:payment, state: 'executed')
        expect(Payment.successful).to include(payment)
      end

      it 'excludes payments with non-successful states' do
        payment = create(:payment, state: 'new')
        expect(Payment.successful).not_to include(payment)
      end
    end

    describe 'failed' do
      it 'includes payments with failed states' do
        payment = create(:payment, state: 'rejected')
        expect(Payment.failed).to include(payment)
      end

      it 'excludes payments with non-failed states' do
        payment = create(:payment, state: 'executed')
        expect(Payment.failed).not_to include(payment)
      end
    end

    describe 'pending' do
      it 'includes payments with pending states' do
        payment = create(:payment, state: 'preauthorized')
        expect(Payment.pending).to include(payment)
      end

      it 'excludes payments with non-pending states' do
        payment = create(:payment, state: 'executed')
        expect(Payment.pending).not_to include(payment)
      end
    end

    describe 'awaiting' do
      it 'includes payments with awaiting states' do
        payment = create(:payment, state: 'timeout')
        expect(Payment.awaiting).to include(payment)
      end

      it 'excludes payments with non-awaiting states' do
        payment = create(:payment, state: 'executed')
        expect(Payment.awaiting).not_to include(payment)
      end
    end

    describe 'uncertain' do
      it 'includes payments with uncertain states' do
        payment = create(:payment, state: 'ssl_error')
        expect(Payment.uncertain).to include(payment)
      end

      it 'excludes payments with non-uncertain states' do
        payment = create(:payment, state: 'executed')
        expect(Payment.uncertain).not_to include(payment)
      end
    end

    describe 'should_be_finalized' do
      let!(:user) { create(:user) }
      let!(:order) { create(:order, user: user) }
      let!(:another_order) { create(:order, user: user) }
      let!(:executed_payment) { create(:payment, :executed, :for_order, payable: order) }
      let!(:to_be_finalized_payment) { create(:payment, :to_be_finalized, :for_order, payable: another_order) }
      it 'includes payments which have executed status for longer than 1 hour' do
        expect(Payment.should_be_finalized).to include(to_be_finalized_payment)
      end

      it 'excludes payments which have executed status for shorter than 1 hour' do
        expect(Payment.should_be_finalized).not_to include(executed_payment)
      end
    end
  end
  describe 'methods' do
    describe 'successful?' do
      it 'returns true if payment state is executed' do
        payment = build(:payment, state: 'executed')
        expect(payment.successful?).to be true
      end

      it 'returns false if payment state is not executed' do
        payment = build(:payment, state: 'new')
        expect(payment.successful?).to be false
      end
    end
    describe 'pending?' do
      it 'returns true for a pending state' do
        payment = build(:payment, state: 'preauthorized')
        expect(payment.pending?).to be true
      end

      it 'returns false for a non-pending state' do
        payment = build(:payment, state: 'executed')
        expect(payment.pending?).to be false
      end
    end

    describe 'uncertain?' do
      it 'returns true for an uncertain state' do
        payment = build(:payment, state: 'timeout')
        expect(payment.uncertain?).to be true
      end

      it 'returns false for a non-uncertain state' do
        payment = build(:payment, state: 'executed')
        expect(payment.uncertain?).to be false
      end
    end

    describe 'awaiting?' do
      it 'returns true for an awaiting state' do
        payment = build(:payment, state: 'ssl_error')
        expect(payment.awaiting?).to be true
      end

      it 'returns false for a non-awaiting state' do
        payment = build(:payment, state: 'executed')
        expect(payment.awaiting?).to be false
      end
    end

    describe 'retryable?' do
      it 'returns true if not successful and not awaiting' do
        payment = build(:payment, state: 'failed')
        expect(payment.retryable?).to be true
      end

      it 'returns false if successful' do
        payment = build(:payment, state: 'executed')
        expect(payment.retryable?).to be false
      end

      it 'returns false if awaiting' do
        payment = build(:payment, state: 'timeout')
        expect(payment.retryable?).to be false
      end
    end

    describe 'simplified_state' do
      it 'returns :success for a success state' do
        payment = build(:payment, state: 'executed')
        expect(payment.simplified_state).to eq(:success)
      end

      it 'returns :failure for a failure state' do
        payment = build(:payment, state: 'rejected')
        expect(payment.simplified_state).to eq(:failure)
      end

      it 'returns :pending for a pending state' do
        payment = build(:payment, state: 'tds_redirected')
        expect(payment.simplified_state).to eq(:pending)
      end

      it 'returns :uncertain for an uncertain state' do
        payment = build(:payment, state: 'ssl_error')
        expect(payment.simplified_state).to eq(:uncertain)
      end

      it 'returns :failure for an unknown state' do
        payment = build(:payment, state: 'some_unknown_status')
        expect(payment.simplified_state).to eq(:failure)
      end
    end

    describe 'update_payment_and_payable_statuses' do
      let(:subscription) { create(:subscription) }
      let(:order)        { create(:order) }

      it 'updates state and associated subscription status' do
        payment = create(:payment, :for_subscription, payable: subscription)
        payment.update_payment_and_payable_statuses('executed')

        expect(payment.state).to eq('executed')
        expect(subscription.reload.status).to eq('Active')
      end

      it 'updates state and associated order status' do
        payment = create(:payment, :for_order, payable: order)
        payment.update_payment_and_payable_statuses('failed')

        expect(payment.state).to eq('failed')
        expect(order.reload.status).to eq('Payment Failed')
      end
    end

    describe 'create_payment' do
      it 'creates payment for provided payable' do
        user = create(:user)
        order = create(:order, user: user)
        payment = ::Payment.create_payment(payable: order)

        expect(payment.payable).to eq(order)
      end
    end

    describe 'process_payment & process_response' do
      let(:user) { create(:user) }
      let(:order) { create(:order, user: user) }
      let(:payment) { ::Payment.create_payment(payable: order) }
      let(:client) { create(:client, :real, :primary) }

      it 'returns redirect_url when processing Secure Web Payment' do
        result_action, result_param = payment.process_payment

        expect(result_action).to eq(:redirect_url)
        expect(result_param).to include(/secure_web_page/)
      end


      it 'returns redirect_url when processing CIT payment' do
        result_action, result_param = payment.process_payment(client_id: client.client_id)

        expect(result_action).to eq(:redirect_url)
        expect(result_param).to include(/secure_web_page/)
      end

      it 'returns response from Espago when processing MIT payment' do
        result_action, result_param = payment.process_payment(client_id: client.client_id, cof: 'recurring')

        expect(result_action).to eq(:success)
        expect(result_param).to eq(payment.payment_number)
      end
    end
  end
end
