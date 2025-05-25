# typed: strict

module Espago
  class Response
    extend T::Sig

    sig { returns(T::Boolean) }
    attr_reader :success

    sig { returns(T.any(Integer, Symbol)) }
    attr_reader :status

    sig { returns(T::Hash[String, T.untyped]) }
    attr_reader :body

    sig do
      params(
        success: T::Boolean,
        status:  T.any(Integer, Symbol),
        body:    T::Hash[String, T.untyped],
      ).void
    end
    def initialize(success:, status:, body:)
      @success = success
      @status = status
      @body = body
    end

    sig { returns(T::Boolean) }
    def success?
      @success
    end
  end
end
