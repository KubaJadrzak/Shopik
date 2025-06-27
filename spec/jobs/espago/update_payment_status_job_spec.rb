require 'rails_helper'

RSpec.describe Espago::UpdatePaymentStatusJob, type: :job do
  let(:user) { create(:user) }
  let(:order) { create(:order, user: user) }
  let!(:payment) { create(:payment, :for_order, payable: order, payment_id: 'PAY123') }

  it 'updates payment status when payment has payment_id and payment status changes' do
    allow(Espago::Payment::PaymentStatusService).to receive(:new)
      .with(payment_id: 'PAY123')
      .and_return(double(fetch_payment_status: 'executed'))

    described_class.perform_now(user.id)

    expect(payment.reload.state).to eq('executed')
  end

  it 'sets status to resigned if payment is old and status unchanged' do
    payment.update!(created_at: 3.hours.ago)

    allow(Espago::Payment::PaymentStatusService).to receive(:new)
      .with(payment_id: 'PAY123')
      .and_return(double(fetch_payment_status: 'new'))

    described_class.perform_now(user.id)

    expect(payment.reload.state).to eq('resigned')
  end

  it 'sets status to failed if payment has no payment_id, is old, and state is Awaiting Payment' do
    payment.update!(created_at: 3.hours.ago, payment_id: nil, state: 'timeout')

    described_class.perform_now(user.id)

    expect(payment.reload.state).to eq('failed')
  end

  it 'does nothing if PaymentStatusService returns nil' do
    allow(Espago::Payment::PaymentStatusService).to receive(:new)
      .with(payment_id: 'PAY123')
      .and_return(double(fetch_payment_status: nil))

    expect { described_class.perform_now(user.id) }
      .not_to raise_error
    expect(payment.reload.state).to eq('new')
  end

  it 'does nothing if user is not found' do
    expect { described_class.perform_now(-1) }
      .not_to raise_error
    expect(payment.reload.state).to eq('new')
  end
end
