# typed: strict
# frozen_string_literal: true

module ClientProcessor
  class Authorize

    #: (::Client) -> void
    def initialize(client)
      @client = client
    end

    #: -> ::ClientProcessor::Response
    def process
      request = Request::Authorize.new(@client)

      response = request.process

      StateManager.new(response).process

      response
    end
  end
end
