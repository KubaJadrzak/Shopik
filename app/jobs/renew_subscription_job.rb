# typed: strict

# frozen_string_litera: true

class RenewSubscriptionJob < ApplicationJob
  queue_as :default

  #: -> void
  def perform
    handle_subscription_renewal
  end

  private

  #: -> void
  def handle_subscription_renewal
    Subscription.should_be_renewed.find_each do |old_subscription|
      ActiveRecord::Base.transaction do
        old_subscription.state = 'Expired'
        old_subscription.save(validate: false)

        user = old_subscription.user #: as !nil

        new_subscription = user.subscriptions.create!(
          state: 'New',
        )

        payment = new_subscription.payments.create!(
          amount:         4.99,
          state:          'new',
          cof:            :recurring,
          payment_method: 'mit',
          currency:       'PLN',
          kind:           :sale,
        )

        client = user.primary_payment_method #: as !nil

        payment_means = client.espago_client_id

        PaymentProcessor::Charge.new(payment: payment, payment_means: payment_means)
      end
    end
  end
end
