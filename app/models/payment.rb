# typed: strict
# frozen_string_literal: true

class Payment < ApplicationRecord
  belongs_to :payable, polymorphic: true
  belongs_to :saved_payment_method, optional: true, touch: true

  validate :must_have_payable
  validate :prevent_duplicate_payment

  before_create :generate_uuid

  delegate :user, to: :payable

  scope :should_be_finalized, -> {
    where(state: 'executed').where('updated_at < ?', 1.hour.ago)
  }

  scope :should_be_checked, -> {
    awaiting.where.not(espago_payment_id: nil)
  }

  scope :should_be_resigned, -> {
    awaiting.where('updated_at < ?', 1.hour.ago)
  }

  enum :payment_method, %i[iframe secure_web_page iframe3 meest_paywall google_pay apple_pay cit mit]
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

  #: -> void
  def must_have_payable
    return if payable.present?

    errors.add(:base, 'Payment must belong to a payable entity')
  end

  #: -> void
  def prevent_duplicate_payment
    return unless payable_id?

    return unless Payment.where(payable: payable).awaiting.exists? ||
                  Payment.where(payable: payable).successful.exists?

    errors.add(:base, 'Cannot create new payment: payable already has an awaiting or successful payment')
  end

  #: -> void
  def generate_uuid
    self.uuid = "pay_#{SecureRandom.uuid}"
  end
end
