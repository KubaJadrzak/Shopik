# typed: strict
# frozen_string_literal: true

class ExpireSubscriptionJob < ApplicationJob
  queue_as :default

  #: -> void
  def perform
    handle_expired_subscriptions
  end

  private

  #: -> void
  def handle_expired_subscriptions
    ::Subscription.should_be_expired.each do |subscription|
      subscription.state = 'Expired'

      subscription.save(validate: false)
    end
  end
end
