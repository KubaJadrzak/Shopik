# typed: true
# frozen_string_literal: true

module Errors::PaymentErrors
  include Kernel
  extend ActiveSupport::Concern


  def payment_error!(message = 'We are experiencing an issue with your payment!')
    raise PaymentError, message
  end
end
