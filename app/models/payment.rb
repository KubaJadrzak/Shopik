# frozen_string_literal: true
# typed: strict

class Payment < ApplicationRecord
  belongs_to :payable, polymorphic: true
  belongs_to :client, optional: true, touch: true

  validate :must_have_payable
  validate :prevent_duplicate_payment_for_order, on: :create, if: :payable_is_order?
  validate :prevent_duplicate_payment_for_subscription, on: :create, if: :payable_is_subscription?
  validate :prevent_duplicate_payable_payment_for_client, on: :create, if: :payable_is_client?

  before_create :generate_payment_number

  scope :should_be_finalized, -> {
    where(state: 'executed').where('updated_at < ?', 1.hour.ago)
  }

  STATUS_MAP = {
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
  }.freeze #: Hash[String, String]

  ORDER_STATUS_MAP = STATUS_MAP.merge('executed'  => 'Preparing for Shipment',
                                      'resigned'  => 'Payment Resigned',
                                      'reversed'  => 'Payment Reversed',
                                      'finalized' => 'Delivered',) #: Hash[String, String]

  SUBSCRIPTION_STATUS_MAP = STATUS_MAP.merge('executed'  => 'Active',
                                             'resigned'  => 'Payment Resigned',
                                             'reversed'  => 'Payment Reversed',
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
    !successful? && !awaiting?
  end

  #: -> bool
  def reversable?
    state == 'executed'
  end

  #: -> bool
  def refundable?
    state == 'finalized'
  end

  #: -> Symbol
  def simplified_state
    return :success if SUCCESS_STATUSES.include?(state)
    return :failure if FAILURE_STATUSES.include?(state)
    return :uncertain if UNCERTAIN_STATUSES.include?(state)
    return :pending if PENDING_STATUSES.include?(state)

    :failure
  end

  class << self
    #: (payable: Client | Subscription | Order) -> Payment
    def create_payment(payable:)
      if payable.instance_of?(Client)
        payable.payable_payments.create(amount: payable.amount, state: 'new')
      else
        payable.payments.create(amount: payable.amount, state: 'new')
      end
    end
  end

  #: -> User?
  def user
    payable&.user
  end

  #: (String) -> void
  def update_payment_and_payable_statuses(state)
    update!(state: state.to_s)

    return unless payable.present?

    update_payable_status
  end

  #: (?card_token: String?, ?cof: String?, ?client_id: String?) -> [Symbol, String]
  def process_payment(card_token: nil, cof: nil, client_id: nil)
    Espago::Payment::Processor.new(
      payment:    self,
      card_token: card_token,
      cof:        cof,
      client_id:  client_id,
    ).process_payment
  end

  #: -> [Symbol, String]
  def reverse_payment
    Espago::Payment::Processor.new(
      payment:    self,
    ).reverse_payment
  end

  #: (Espago::Payment::Response) -> [Symbol, String]
  def process_response(response)
    Espago::Payment::ResponseProcessor.new(payment: self, response: response).process_response
  end

  private

  #: -> void
  def update_payable_status
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
      if payable.status == 'Active' && new_status != 'Active'
        Rails.logger.info("Subscription #{payable.id} is Active; ignoring status change")
      else
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
    payable.is_a?(::Client)
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

    errors.add(:base, 'Cannot create new payment: order already has a payment awaiting or successful')
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
  def generate_payment_number
    self.payment_number = SecureRandom.hex(10).upcase
  end
end
