# typed: true
# frozen_string_literal: true

module Errors::SubscriptionErrors
  include Kernel
  extend ActiveSupport::Concern


  def subscription_error!(message = 'We are experiencing an issue with your subscription!')
    raise SubscriptionError, message
  end
end
