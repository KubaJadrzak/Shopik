# typed: strict

class Payment < ApplicationRecord
  extend T::Sig
  belongs_to :subscription, optional: true
  belongs_to :order, optional: true
  delegate :espago_client, to: :subscription

  validate :must_have_subscription_or_order
  validate :prevent_duplicate_payment_for_order, on: :create

  before_create :generate_payment_number


  ORDER_STATUS_MAP = T.let({
                             'executed'              => 'Preparing for Shipment',
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

  SUBSCRIPTION_STATUS_MAP = T.let({
                                    'executed'              => 'Active',
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

  sig { params(state: String).void }
  def update_status_by_payment_status(state)
    self.state = state
    save!



    if subscription.present?
      new_status = SUBSCRIPTION_STATUS_MAP[state] || 'Payment Error'
      T.must(subscription).update!(status: new_status)
    elsif order.present?
      new_status = ORDER_STATUS_MAP[state] || 'Payment Error'
      T.must(order).update!(status: new_status)
    else
      Rails.logger.warn("Payment #{id} does not belong to a subscription or order.")
    end
  end

  sig { params(state: String).returns(String) }
  def show_status_by_payment_status(state)
    if subscription.present?
      SUBSCRIPTION_STATUS_MAP[state] || 'Payment Error'
    else
      ORDER_STATUS_MAP[state] || 'Payment Error'
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

  scope :in_progress, -> { where(state: IN_PROGRESS_STATUSES) }

  sig { returns(T::Boolean) }
  def in_progress?
    IN_PROGRESS_STATUSES.include?(state)
  end

  sig { returns(T::Boolean) }
  def successful?
    state == 'executed'
  end

  sig { returns(T::Boolean) }
  def retryable?
    !in_progress? && !successful?
  end


  private

  sig { void }
  def must_have_subscription_or_order
    return unless subscription.nil? && order.nil?

    errors.add(:base, 'Payment must belong to either a subscription or an order')
  end

  sig { void }
  def prevent_duplicate_payment_for_order
    return unless order.present?
    return unless Payment.where(order: order).where(state: IN_PROGRESS_STATUSES + ['executed']).exists?

    errors.add(:base, 'Cannot create new payment: order already has a payment in progress or successful')


  end

  sig { void }
  def generate_payment_number
    self.payment_number = SecureRandom.hex(10).upcase
  end
end
