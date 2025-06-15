require 'rails_helper'

RSpec.describe Client, type: :model do

  describe 'callbacks' do
    it 'generates client_number before create' do
      client = build(:client, client_number: nil)
      expect(client.client_number).to be_nil

      client.save!

      expect(client.client_number).to be_present
      expect(client.client_number.length).to eq(20) # hex(10) * 2 chars per byte
      expect(client.client_number).to eq(client.client_number.upcase)
    end
  end

  describe 'scopes' do
    describe '.cit' do
      it 'returns clients with status CIT' do
        cit_client = create(:client, status: 'CIT')
        other_client = create(:client, status: 'MIT')

        expect(Client.cit).to include(cit_client)
        expect(Client.cit).not_to include(other_client)
      end
    end

    describe '.mit' do
      it 'returns clients with status MIT' do
        mit_client = create(:client, status: 'MIT')
        other_client = create(:client, status: 'CIT')

        expect(Client.mit).to include(mit_client)
        expect(Client.mit).not_to include(other_client)
      end
    end
  end
end
