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

  delegate :user, to: :payable

  scope :should_be_finalized, -> {
    where(state: 'executed').where('updated_at < ?', 1.hour.ago)
  }

  scope :should_be_checked, -> {
    awaiting.where.not(espago_payment_id: nil)
  }

  enum :payment_method, %i[iframe secure_web_page iframe3 meest_paywall google_pay apple_pay]
  enum :cof, %i[storing recurring unscheduled]
  enum :kind, %i[sale preauth]

  scope :successful, -> { where(state: SUCCESS_STATUSES) }
  scope :failed, -> { where(state: REJECTED_STATUSES) }
  scope :pending, -> { where(state: PENDING_STATUSES) }
  scope :awaiting, -> { where(state: AWAITING_STATUSES) }
  scope :uncertain, -> { where(state: UNCERTAIN_STATUSES) }

  #: -> String
  def to_param
    uuid
  end

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
    return :rejected if REJECTED_STATUSES.include?(state)
    return :uncertain if UNCERTAIN_STATUSES.include?(state)
    return :pending if PENDING_STATUSES.include?(state)
    return :awaiting if AWAITING_STATUSES.include?(state)

    :failed
  end

  #: -> String?
  def json_response
    raw_response = response
    return unless raw_response

    ::JSON.parse(raw_response)
  end

  private

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

    errors.add(:base, 'Cannot create new payment: subscription already has an awaiting payment')
  end

  #: -> void
  def prevent_duplicate_payable_payment_for_client
    return unless payable_is_client?

    return unless Payment.where(payable: payable).awaiting.exists?

    errors.add(:base, 'Cannot create new payment: client already has an awaiting payment')
  end

  #: -> void
  def generate_uuid
    self.uuid = "pay_#{SecureRandom.uuid}"
  end
end
