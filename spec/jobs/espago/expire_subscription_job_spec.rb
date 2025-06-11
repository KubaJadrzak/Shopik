# spec/jobs/espago/expire_subscription_job_spec.rb
require 'rails_helper'

RSpec.describe Espago::ExpireSubscriptionJob, type: :job do
  describe '#perform' do
    let!(:expired_subscription) { create(:subscription, status: 'Active', end_date: 1.day.ago) }
    let!(:active_subscription) { create(:subscription, status: 'Active', end_date: 1.day.from_now) }

    it 'updates status of expired subscriptions to Expired' do
      expect do
        described_class.perform_now
      end.to change { expired_subscription.reload.status }
        .from('Active').to('Expired')
    end

    it 'does not update active subscriptions with future end_date' do
      expect do
        described_class.perform_now
      end.not_to(change { active_subscription.reload.status })
    end
  end
end
