# typed: strict

class Espago::Response
  extend T::Sig

  sig { returns(T::Boolean) }
  attr_reader :success

  sig { returns(String) }
  attr_reader :status

  sig { returns(T::Hash[String, T.untyped]) }
  attr_reader :body

  sig do
    params(success: T::Boolean, status: T.any(String, Symbol, Integer), body: T::Hash[String, T.untyped]).void
  end
  def initialize(success:, status:, body:)
    @success = success
    @status = T.let(status.to_s, String)
    @body = body
  end

  sig { returns(T::Boolean) }
  def success?
    @success
  end
end
