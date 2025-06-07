class Charge < ApplicationRecord
  extend T::Sig
  belongs_to :subscription, optional: true
  belongs_to :order, optional: true
  delegate :espago_client, to: :subscription

  before_create :generate_charge_number


  STATUS_MAP = T.let({
                       'executed'              => 'Payment Successful',
                       'rejected'              => 'Payment Rejected',
                       'failed'                => 'Payment Failed',
                       'resigned'              => 'Payment Resigned',
                       'reversed'              => 'Payment Reversed',
                       'preauthorized'         => 'Waiting for Payment',
                       'tds2_challenge'        => 'Waiting for Payment',
                       'tds_redirected'        => 'Waiting for Payment',
                       'dcc_decision'          => 'Waiting for Payment',
                       'blik_redirected'       => 'Waiting for Payment',
                       'transfer_redirected'   => 'Waiting for Payment',
                       'new'                   => 'Waiting for Payment',
                       'refunded'              => 'Payment Refunded',

                       'timeout'               => 'Awaiting Payment',
                       'connection_failed'     => 'Awaiting Payment',
                       'ssl_error'             => 'Awaiting Payment',
                       'parsing_error'         => 'Awaiting Payment',
                       'unknown_faraday_error' => 'Awaiting Payment',
                       'unexpected_error'      => 'Awaiting Payment',

                       'invalid_uri'           => 'Payment Error',
                     }, T::Hash[String, String],)

  def update_status_by_payment_status(state)
    self.state = state
    save!

    new_status = STATUS_MAP[state] || 'Payment Error'

    if subscription.present?
      subscription.update!(status: new_status)
    elsif order.present?
      order.update!(status: new_status)
    else
      Rails.logger.warn("Charge #{id} does not belong to a subscription or order.")
    end
  end



  IN_PROGRESS_STATUSES = T.let(
    %w[
      preauthorized
      tds2_challenge
      tds_redirected
      dcc_decision
      blik_redirected
      transfer_redirected
      new
      timeout
      connection_failed
      ssl_error
      parsing_error
      unknown_faraday_error
      unexpected_error
    ].freeze,
    T::Array[String],
  )

  FINAL_STATUSES = T.let(
    %w[
      executed
      rejected
      failed
      resigned
      reversed
      refunded
      invalid_uri
    ].freeze,
    T::Array[String],
  )

  def in_progress?
    IN_PROGRESS_STATUSES.include?(payment_status)
  end

  def self.in_progress_for_order(order)
    order.charges.find { |c| c.in_progress? }
  end


  private

  def must_have_subscription_or_order
    return unless subscription.nil? && order.nil?

    errors.add(:base, 'Charge must belong to either a subscription or an order')

  end

  def generate_charge_number
    self.charge_number = SecureRandom.hex(10).upcase
  end
end
