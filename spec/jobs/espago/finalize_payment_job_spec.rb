# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Espago::FinalizePaymentJob, type: :job do
  describe '#perform' do
    let!(:user) { create(:user) }
    let!(:order) { create(:order, user: user) }
    let!(:another_order) { create(:order, user: user) }
    let!(:executed_payment) { create(:payment, :executed, :for_order, payable: order) }
    let!(:to_be_finalized_payment) { create(:payment, :to_be_finalized, :for_order, payable: another_order) }

    it 'finalizes only payments that are executed for longer than 1 hour' do
      described_class.perform_now

      expect(executed_payment.reload.state).to eq('executed')
      expect(to_be_finalized_payment.reload.state).to eq('finalized')
    end
  end
end
