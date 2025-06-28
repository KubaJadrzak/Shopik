# typed: strict

class Payment < ApplicationRecord
  extend T::Sig
  belongs_to :payable, polymorphic: true
  belongs_to :client, optional: true

  validate :must_have_payable
  validate :prevent_duplicate_payment_for_order, on: :create, if: :payable_is_order?
  validate :prevent_duplicate_payment_for_subscription, on: :create, if: :payable_is_subscription?

  before_create :generate_payment_number

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

  ORDER_STATUS_MAP = STATUS_MAP.merge('executed' => 'Preparing for Shipment') #: Hash[String, String]

  SUBSCRIPTION_STATUS_MAP = STATUS_MAP.merge('executed' => 'Active') #: Hash[String, String]

  CLIENT_STATUS_MAP = Hash.new('Unverified').merge('executed' => 'CIT') #: Hash[String, String]

  SUCCESS_STATUSES = ['executed'].freeze #: Array[String]

  FAILURE_STATUSES = %w[rejected failed resigned reversed refunded invalid_uri].freeze #: Array[String]

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
  def update_status_by_payment_status(state)
    self.state = state
    save!

    return unless payable.present?

    update_status
  end

  private

  #: -> void
  def update_status
    set_new_status
    handle_status_update
  end

  #: -> void
  def set_new_status
    @new_status = case payable
                  when Subscription
                    SUBSCRIPTION_STATUS_MAP[state] || 'Payment Error'
                  when Order
                    ORDER_STATUS_MAP[state] || 'Payment Error'
                  when Client
                    CLIENT_STATUS_MAP[state] || 'Unverified'
                  else
                    'Payment Error'
                  end  #: String?

  end

  #: -> void
  def handle_status_update
    new_status = @new_status #: as !nil
    if payable.is_a?(Subscription)
      if payable.status == 'Active' && new_status != 'Active'
        Rails.logger.info("Subscription #{payable.id} is Active; ignoring status change")
      else
        payable.update!(status: new_status)
        payable.extend_or_initialize_dates! if new_status == 'Active'
      end
    elsif payable.is_a?(Order) || payable.is_a?(Client)
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

  #: -> void
  def must_have_payable
    return if payable.present?

    errors.add(:base, 'Payment must belong to a payable entity')
  end

  #: -> void
  def prevent_duplicate_payment_for_order
    return unless payable_is_order?

    return unless Payment.where(payable: payable).awaiting.exists?

    errors.add(:base, 'Cannot create new payment: order already has a payment awaiting or successful')
  end

  #: -> void
  def prevent_duplicate_payment_for_subscription
    return unless payable_is_subscription?
    return unless Payment.where(payable: payable).awaiting.exists?

    errors.add(:base, 'Cannot create new payment: subscription already has a pending or uncertain payment')
  end

  #: -> void
  def generate_payment_number
    self.payment_number = SecureRandom.hex(10).upcase
  end
end
