# typed: true
# frozen_string_literal: true

module SavedPaymentMethodErrors
  include Kernel
  extend ActiveSupport::Concern


  def saved_payment_method_error!(message = 'We are experiencing an issue with your Saved Payment Method!')
    raise SavedPaymentMethodError, message
  end
end
