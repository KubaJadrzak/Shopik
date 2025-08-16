# frozen_string_literal: true
# typed:strict

require 'sidekiq-scheduler'
module Espago
  class FinalizePaymentJob < ApplicationJob
    queue_as :default

    #: -> void
    def perform
      ::Payment.should_be_finalized.find_each do |payment|
        payment.update_payment_and_payable_statuses('finalized')
      end
    end
  end
end
