require 'rails_helper'

RSpec.describe Espago::Payment::StatusService do
  let(:payment_id) { 'payment_123' }
  let(:client_double) { instance_double('Client') }
  let(:service) { described_class.new(payment_id: payment_id) }

  before do
    service.instance_variable_set(:@client, client_double)
  end

  describe '#fetch_payment_status' do
    context 'when the client response is successful' do
      response = Espago::Payment::Response.new(
        success: true,
        status:  200,
        body:    { 'state' => 'executed' },
      )

      it 'returns the payment state from the response body' do
        expect(client_double).to receive(:send)
          .with("api/charges/#{payment_id}", method: :get)
          .and_return(response)

        expect(Rails.logger).to receive(:info).with(/Successfully fetched payment status for #{payment_id}/)

        result = service.fetch_payment_status
        expect(result).to eq('executed')
      end
    end

    context 'when the client response is unsuccessful' do
      response = Espago::Payment::Response.new(
        success: false,
        status:  500,
        body:    { 'error' => 'Internal Server Error' },
      )


      it 'logs an error and returns nil' do
        expect(client_double).to receive(:send)
          .with("api/charges/#{payment_id}", method: :get)
          .and_return(response)

        expect(Rails.logger).to receive(:error).with(/Failed to fetch payment status for #{payment_id}/)

        result = service.fetch_payment_status
        expect(result).to be_nil
      end
    end
  end
end
