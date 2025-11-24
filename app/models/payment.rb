# frozen_string_literal: true
# typed: strict

class Payment < ApplicationRecord
  belongs_to :payable, polymorphic: true
  belongs_to :client, optional: true, touch: true

  validate :must_have_payable
  validate :prevent_duplicate_payment_for_order, on: :create, if: :payable_is_order?
  validate :prevent_duplicate_payment_for_subscription, on: :create, if: :payable_is_subscription?
  validate :prevent_duplicate_payable_payment_for_client, on: :create, if: :payable_is_client?

  before_create :generate_uuid

  scope :should_be_finalized, -> {
    where(state: 'executed').where('updated_at < ?', 1.hour.ago)
  }

  enum :payment_method, %i[iframe secure_web_page iframe3 meest_paywall google_pay apple_pay]
  enum :cof, %i[storing recurring unscheduled]
  enum :kind, %i[sale preauth]

  STATUS_MAP = {
    'rejected'              => 'Payment Rejected',
    'failed'                => 'Payment Failed',
    'resigned'              => 'Payment Resigned',
    'reversed'              => 'Cancelled',
    'preauthorized'         => 'Payment in Progress',
    'tds2_challenge'        => 'Payment in Progress',
    'tds_redirected'        => 'Payment in Progress',
    'dcc_decision'          => 'Payment in Progress',
    'blik_redirected'       => 'Payment in Progress',
    'transfer_redirected'   => 'Payment in Progress',
    'new'                   => 'Payment in Progress',
    'refunded'              => 'Returned',
    'timeout'               => 'Waiting for Payment',
    'connection_failed'     => 'Waiting for Payment',
    'ssl_error'             => 'Waiting for Payment',
    'parsing_error'         => 'Waiting for Payment',
    'unknown_faraday_error' => 'Waiting for Payment',
    'unexpected_error'      => 'Waiting for Payment',
    'invalid_uri'           => 'Payment Error',
  }.freeze #: Hash[String, String]

  ORDER_STATUS_MAP = STATUS_MAP.merge('executed'  => 'Preparing for Shipment',
                                      'finalized' => 'Delivered',) #: Hash[String, String]

  SUBSCRIPTION_STATUS_MAP = STATUS_MAP.merge('executed'  => 'Active',
                                             'finalized' => 'Active',) #: Hash[String, String]

  SUCCESS_STATUSES = %w[executed
                        finalized].freeze #: Array[String]

  FAILURE_STATUSES = %w[
    rejected
    failed
    resigned
    invalid_uri
  ].freeze #: Array[String]

  PENDING_STATUSES = %w[
    preauthorized
    tds2_challenge
    tds_redirected
    dcc_decision
    blik_redirected
    transfer_redirected
    new
  ].freeze #: Array[String]

  UNCERTAIN_STATUSES = %w[
    timeout
    connection_failed
    ssl_error
    parsing_error
    unknown_faraday_error
    unexpected_error
  ].freeze #: Array[String]

  AWAITING_STATUSES = (PENDING_STATUSES + UNCERTAIN_STATUSES).freeze #: Array[String]

  scope :successful, -> { where(state: SUCCESS_STATUSES) }
  scope :failed, -> { where(state: FAILURE_STATUSES) }
  scope :pending, -> { where(state: PENDING_STATUSES) }
  scope :awaiting, -> { where(state: AWAITING_STATUSES) }
  scope :uncertain, -> { where(state: UNCERTAIN_STATUSES) }

  #: -> bool
  def pending?
    PENDING_STATUSES.include?(state)
  end

  #: -> bool
  def uncertain?
    UNCERTAIN_STATUSES.include?(state)
  end

  #: -> bool
  def awaiting?
    AWAITING_STATUSES.include?(state)
  end

  #: -> bool
  def successful?
    SUCCESS_STATUSES.include?(state)
  end

  #: -> bool
  def retryable?
    !successful? && !awaiting? && !refunded?
  end

  #: -> bool
  def reversable?
    state == 'executed'
  end

  #: -> bool
  def refundable?
    state == 'finalized'
  end

  #: -> bool
  def reversed?
    state == 'reversed'
  end

  #: -> bool
  def refunded?
    state == 'refunded'
  end

  #: -> Symbol
  def simplified_state
    return :success if SUCCESS_STATUSES.include?(state)
    return :failure if FAILURE_STATUSES.include?(state)
    return :uncertain if UNCERTAIN_STATUSES.include?(state)
    return :pending if PENDING_STATUSES.include?(state)

    :failure
  end

  #: -> User?
  def user
    payable&.user
  end

  #: (String) -> void
  def update_payment_and_payable_statuses(state)
    update!(state: state.to_s)

    return unless payable.present?

    set_new_payable_status
  end

  #: -> [Symbol, String]
  def reverse_payment
    Payment::PaymentProcessor.new(
      payment:    self,
    ).reverse_payment
  end

  #: -> [Symbol, String]
  def refund_payment
    Payment::PaymentProcessor.new(
      payment:    self,
    ).refund_payment
  end

  #: (Payment) -> [Symbol, String]
  def process_response(response)
    Payment::ResponseProcessor.new(payment: self, response: response).process_response
  end

  private

  #: -> void
  def update_status
    set_new_payable_status
    handle_payable_status_update
  end

  #: -> void
  def set_new_payable_status
    @new_status = case payable
                  when Subscription
                    SUBSCRIPTION_STATUS_MAP[state] || 'Payment Error'
                  when Order
                    ORDER_STATUS_MAP[state] || 'Payment Error'
                  else
                    'Payment Error'
                  end  #: String?

  end

  #: -> void
  def handle_payable_status_update
    new_status = @new_status #: as !nil
    if payable.is_a?(Subscription)
      unless payable.status == 'Active' && new_status != 'Active'
        payable.update!(status: new_status)
        payable.extend_or_initialize_dates! if new_status == 'Active'
      end
    elsif payable.is_a?(Order)
      payable.update!(status: new_status)
    end

  end

  #: -> bool
  def payable_is_order?
    payable.is_a?(Order)
  end

  #: -> bool
  def payable_is_subscription?
    payable.is_a?(Subscription)
  end

  #: -> bool
  def payable_is_client?
    payable.is_a?(Client)
  end

  #: -> void
  def must_have_payable
    return if payable.present?

    errors.add(:base, 'Payment must belong to a payable entity')
  end

  #: -> void
  def prevent_duplicate_payment_for_order
    return unless payable_is_order?

    return unless Payment.where(payable: payable).awaiting.exists? ||
                  Payment.where(payable: payable).successful.exists?

    errors.add(:base, 'Cannot create new payment: order already has an awaiting or successful payment')
  end

  #: -> void
  def prevent_duplicate_payment_for_subscription
    return unless payable_is_subscription?

    return unless Payment.where(payable: payable).awaiting.exists?

    errors.add(:base, 'Cannot create new payment: subscription already has a pending or uncertain payment')
  end

  #: -> void
  def prevent_duplicate_payable_payment_for_client
    return unless payable_is_client?

    return unless Payment.where(payable: payable).awaiting.exists?

    errors.add(:base, 'Cannot create new payment: client already has an awaiting payable payment')
  end

  #: -> void
  def generate_uuid
    self.uuid = "pay_#{SecureRandom.uuid}"
  end
end
