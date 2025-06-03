require 'rails_helper'

RSpec.describe Espago::UpdatePaymentStatusJob, type: :job do
  let(:user) { create(:user) }
  let!(:order) { create(:order, user: user, payment_status: 'new', status: 'New', payment_id: 'pay_123') }

  it 'updates order status when order has payment_id and payment status changes' do

    allow(Espago::PaymentStatusService).to receive(:new)
      .with(payment_id: 'pay_123')
      .and_return(double(fetch_payment_status: 'executed'))

    described_class.perform_now(user.id)

    expect(order.reload.payment_status).to eq('executed')
  end

  it 'sets status to resigned if order has payment_id, is old and status unchanged' do
    order.update!(created_at: 3.hours.ago)

    allow(Espago::PaymentStatusService).to receive(:new)
      .with(payment_id: 'pay_123')
      .and_return(double(fetch_payment_status: 'new'))

    described_class.perform_now(user.id)

    expect(order.reload.payment_status).to eq('resigned')
  end

  it 'sets status of order without payment_id and with uncertain error to failed if orders is old' do

    order.update!(created_at: 3.hours.ago, payment_id: nil, payment_status: 'timeout', status: 'Awaiting Payment')
    described_class.perform_now(user.id)

    expect(order.reload.payment_status).to eq('failed')
  end

  it 'does nothing if PaymentStatusService returns nil' do

    allow(Espago::PaymentStatusService).to receive(:new)
      .with(payment_id: 'pay_123')
      .and_return(double(fetch_payment_status: nil))

    expect { described_class.perform_now(user.id) }
      .not_to raise_error

    expect(order.reload.payment_status).to eq('new')

  end

  it 'does nothing if user is not found' do
    expect { described_class.perform_now(-1) }
      .not_to raise_error

    expect(order.reload.payment_status).to eq('new')
  end
end
