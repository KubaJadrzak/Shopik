# typed: strict
# frozen_string_literal: true

module ClientProcessor
  class StateManager
    #: (::ClientProcessor::Response) -> void
    def initialize(response)
      @response = response
      @type = response.type #: Symbol?
      @client = response.client #: ::Client?
    end

    #: -> void
    def process
      authorize_client if @type == :authorize
    end

    #: -> void
    def authorize_client
      return unless @client && @response.communication_success?

      @client.state = 'mit_verified'
      @client.save(validate: false)
    end
  end
end
