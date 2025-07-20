# frozen_string_literal: true
# typed:strict

require 'sidekiq-scheduler'
module Espago
  class ExpireSubscriptionJob < ApplicationJob
    queue_as :default

    #: -> void
    def perform
      Subscription.should_be_expired.find_each do |subscription|
        subscription.update!(status: 'Expired')
      end
    end
  end
end
