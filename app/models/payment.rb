# typed: ignore

class Payment < ApplicationRecord
  extend T::Sig
  belongs_to :subscription, optional: true
  belongs_to :order, optional: true
  delegate :espago_client, to: :subscription

  validate :must_have_subscription_or_order

  before_create :generate_payment_number
  before_create :prevent_duplicate_payment


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


  sig { params(state: String).void }
  def update_status_by_payment_status(state)
    self.state = state
    save!

    new_status = STATUS_MAP[state] || 'Payment Error'

    if subscription.present?
      subscription.update!(status: new_status)
    elsif order.present?
      order.update!(status: new_status)
    else
      Rails.logger.warn("Payment #{id} does not belong to a subscription or order.")
    end
  end

  sig { params(state: String).returns(String) }
  def show_status_by_payment_status(state)
    STATUS_MAP[state] || 'Payment Error'
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

  def must_have_subscription_or_order
    return unless subscription.nil? && order.nil?

    errors.add(:base, 'Payment must belong to either a subscription or an order')
  end

  def prevent_duplicate_payment
    if subscription.present?
      if Payment.where(subscription: subscription).where(state: IN_PROGRESS_STATUSES + ['executed']).exists?
        errors.add(:base, 'Cannot create new payment: subscription already has a payment in progress or successful')
      end
    elsif order.present?
      if Payment.where(order: order).where(state: IN_PROGRESS_STATUSES + ['executed']).exists?
        errors.add(:base, 'Cannot create new payment: order already has a payment in progress or successful')
      end
    end
  end

  def generate_payment_number
    self.payment_number = SecureRandom.hex(10).upcase
  end
end
