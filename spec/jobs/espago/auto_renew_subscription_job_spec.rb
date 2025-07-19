# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Espago::AutoRenewSubscriptionJob, type: :job do
  describe '#perform' do
    let!(:user) { create(:user) }
    let!(:client) { create(:client, :primary, :real, user: user) }
    let!(:renewable_subscription) do
      create(:subscription, auto_renew: true, end_date: Date.current + 1.day,  user: user)
    end
    let!(:not_yet_expired_subscription) do
      create(:subscription, auto_renew: true, end_date: Date.current + 5.days, user: user)
    end
    let!(:non_renewable_subscription) do
      create(:subscription, auto_renew: false, end_date: Date.current + 1.day, user: user)
    end

    it 'renews only subscriptions that should be renewed' do
      described_class.perform_now

      expect(renewable_subscription.reload.end_date.to_date).to eq(Date.current + 31.days)
      expect(not_yet_expired_subscription.reload.end_date.to_date).to eq(Date.current + 5.days)
      expect(non_renewable_subscription.reload.end_date.to_date).to eq(Date.current + 1.days)
    end
  end
end
