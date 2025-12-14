# typed: strict
# frozen_string_literal: true

class RenewSubscriptionJob < ApplicationJob
  queue_as :default

  #: -> void
  def perform
    handle_subscription_renewal
  end

  private

  #: -> void
  def handle_subscription_renewal
    User.should_renew_subscription.find_each do |user|
      saved_payment_methods = user.primary_payment_method
      next unless saved_payment_methods.present?

      payment_means = saved_payment_methods.espago_client_id
      next unless payment_means.present?

      subscription = user.subscriptions.create!(state: 'New')

      payment = subscription.payments.create!(
        amount:         4.99,
        state:          'new',
        cof:            :recurring,
        payment_method: 'mit',
        currency:       'PLN',
        kind:           :sale,
      )

      ::PaymentProcessor::Charge.new(payment: payment, payment_means: payment_means).process
    end
  end
end
