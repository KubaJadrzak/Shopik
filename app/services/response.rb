# typed: strict
# frozen_string_literal: true


class Response
  #: Integer?
  attr_reader :status

  #: Hash[String, untyped]
  attr_reader :body

  #: Symbol?
  attr_accessor :type

  #: (connected: bool, body: Hash[String, untyped], ?status: Integer?) -> void
  def initialize(connected:, body:, status: nil)
    @connected = connected
    @status = status
    @body = body
    @type = nil #: Symbol?
  end

  #: -> bool
  def connected?
    @connected
  end

  #: -> bool
  def communication_success?
    return false unless connected? && @status.present?

    @status.between?(200, 299)
  end

  #: -> bool
  def communication_failure?
    connected? && !communication_success?
  end

  #: -> bool
  def communication_uncertain?
    !connected?
  end
end
