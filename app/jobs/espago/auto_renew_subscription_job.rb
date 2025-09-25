# frozen_string_literal: true
# typed:strict

require 'sidekiq-scheduler'
module Espago
  class AutoRenewSubscriptionJob < ApplicationJob
    queue_as :default

    #: -> void
    def perform
      Subscription.should_be_renewed.find_each(&:renew)
    end
  end
end
