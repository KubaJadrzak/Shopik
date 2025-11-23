# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Client, type: :model do

  describe 'callbacks' do
    context 'generate_uuid' do
      it 'generates uuid before creation' do
        client = build(:client, uuid: nil)
        expect(client.uuid).to be_nil

        client.save!

        expect(client.uuid).to be_present
        expect(client.uuid.length).to eq(20)
        expect(client.uuid).to eq(client.uuid.upcase)
      end
    end
  end

  describe 'validations' do
    it 'prevent_duplicate_primary' do
      user = create(:user)
      create(:client, :primary, user: user)
      other_primary_client = build(:client, :primary, user: user)

      expect(other_primary_client.save).to be false
      expect(other_primary_client.errors[:base]).to include('This user already has a primary Client')
    end

    it 'ensure_primary_is_mit' do
      primary_client = build(:client, status: 'CIT', primary: true)

      expect(primary_client.save).to be false
      expect(primary_client.errors[:base]).to include('Client must have status MIT to be primary')
    end

    it 'prevent_auto_renew_subscription_with_no_primary' do
      user = create(:user)
      primary_client = create(:client, :primary, user: user)
      create(:subscription, auto_renew: true, user: user)

      expect(primary_client.update(primary: false)).to be false
      expect(primary_client.errors[:base]).to include(
        'Cannot remove primary payment method with auto-renew subscription',
      )
    end

  end

  describe 'scopes' do
    context 'cit' do
      it 'returns clients with status CIT or MIT' do
        other_client = create(:client, status: 'unverified')
        cit_client = create(:client, status: 'CIT')
        mit_client = create(:client, status: 'MIT')

        expect(Client.cit).to include(cit_client)
        expect(Client.cit).to include(mit_client)
        expect(Client.cit).not_to include(other_client)
      end
    end

    context 'mit' do
      it 'returns clients with status MIT' do
        mit_client = create(:client, status: 'MIT')
        other_client = create(:client, status: 'CIT')

        expect(Client.mit).to include(mit_client)
        expect(Client.mit).not_to include(other_client)
      end
    end
  end
end
