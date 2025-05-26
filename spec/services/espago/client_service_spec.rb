require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Espago::ClientService, type: :service do
  let(:client) { described_class.new }

  describe '#send' do
    context 'when the request is successful' do
      before do
        stub_request(:post, 'https://sandbox.espago.com/api/secure_web_page_register')
          .to_return(
            status:  200,
            body:    {
              id:           'payment_id_123',
              redirect_url: 'https://sandbox.espago.com/secure_web_page/payment_id_123',
            }.to_json,
            headers: { 'Content-Type' => 'application/json' },
          )
      end

      it 'returns a successful response with redirect URL' do
        response = client.send(
          'api/secure_web_page_register',
          method: :post,
        )

        expect(response.success?).to eq(true)
        expect(response.status).to eq(200)
        expect(response.body['redirect_url']).to eq('https://sandbox.espago.com/secure_web_page/payment_id_123')
      end
    end

    context 'when the request results in a connection failure' do
      before do
        stub_request(:post, 'https://sandbox.espago.com/api/secure_web_page_register')
          .to_raise(Faraday::ConnectionFailed.new('Connection failed'))
      end

      it 'returns a failed response with a connection error' do
        response = client.send(
          'api/secure_web_page_register',
          method: :post,
        )

        expect(response.success?).to eq(false)
        expect(response.status).to eq(:connection_failed)
        expect(response.body).to eq({ 'error' => 'Connection failed' })
      end
    end
    context 'when the request times out' do
      before do
        stub_request(:post, 'https://sandbox.espago.com/api/secure_web_page_register')
          .to_raise(Faraday::TimeoutError.new('timeout error'))
      end

      it 'returns a timeout error' do
        response = client.send('api/secure_web_page_register', method: :post)
        expect(response.success?).to eq(false)
        expect(response.status).to eq(:timeout)
        expect(response.body).to eq({ 'error' => 'timeout error' })
      end
    end

    context 'when there is an SSL error' do
      before do
        stub_request(:post, 'https://sandbox.espago.com/api/secure_web_page_register')
          .to_raise(Faraday::SSLError.new('SSL error'))
      end

      it 'returns an ssl_error response' do
        response = client.send('api/secure_web_page_register', method: :post)
        expect(response.success?).to eq(false)
        expect(response.status).to eq(:ssl_error)
        expect(response.body).to eq({ 'error' => 'SSL error' })
      end
    end

    context 'when a client error occurs with response' do
      before do
        response_double = instance_double(Faraday::Response,
                                          status: 401,
                                          body:   { 'error' => 'Client Error' },)
        error = Faraday::ClientError.new('client error', response_double)
        stub_request(:post, 'https://sandbox.espago.com/api/secure_web_page_register')
          .to_raise(error)
      end

      it 'returns the client error response code' do
        response = client.send('api/secure_web_page_register', method: :post)
        expect(response.success?).to eq(false)
        expect(response.status).to eq(401)
        expect(response.body).to eq({ 'error' => 'Client Error' })
      end
    end

    context 'when a server error occurs with response' do
      before do
        response_double = instance_double(Faraday::Response,
                                          status: 500,
                                          body:   { 'error' => 'Server error' },)
        error = Faraday::ServerError.new('server error', response_double)
        stub_request(:post, 'https://sandbox.espago.com/api/secure_web_page_register')
          .to_raise(error)
      end

      it 'returns the server error response code' do
        response = client.send('api/secure_web_page_register', method: :post)
        expect(response.success?).to eq(false)
        expect(response.status).to eq(500)
        expect(response.body).to eq({ 'error' => 'Server error' })
      end
    end

    context 'when a parsing error occurs' do
      before do
        stub_request(:post, 'https://sandbox.espago.com/api/secure_web_page_register')
          .to_raise(Faraday::ParsingError.new('parsing error'))
      end

      it 'returns a parsing_error response' do
        response = client.send('api/secure_web_page_register', method: :post)
        expect(response.success?).to eq(false)
        expect(response.status).to eq(:parsing_error)
        expect(response.body).to eq({ 'error' => 'parsing error' })
      end
    end

    context 'when a generic Faraday::Error occurs' do
      before do
        stub_request(:post, 'https://sandbox.espago.com/api/secure_web_page_register')
          .to_raise(Faraday::Error.new('generic faraday error'))
      end

      it 'returns unknown_faraday_error' do
        response = client.send('api/secure_web_page_register', method: :post)
        expect(response.success?).to eq(false)
        expect(response.status).to eq(:unknown_faraday_error)
        expect(response.body).to eq({ 'error' => 'generic faraday error' })
      end
    end

    context 'when an unexpected error occurs' do
      before do
        stub_request(:post, 'https://sandbox.espago.com/api/secure_web_page_register')
          .to_raise(StandardError.new('something went wrong'))
      end

      it 'returns an unexpected_error response' do
        response = client.send('api/secure_web_page_register', method: :post)
        expect(response.success?).to eq(false)
        expect(response.status).to eq(:unexpected_error)
        expect(response.body).to eq({ 'error' => 'something went wrong' })
      end
    end
  end
end
