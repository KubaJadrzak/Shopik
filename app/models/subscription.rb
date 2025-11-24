# frozen_string_literal: true
# typed: strict

class Subscription < ApplicationRecord

  validates :price, presence: true

  validate :auto_renew_requires_primary_payment_method, if: :will_save_change_to_auto_renew?
  validate :cannot_have_dates_when_not_active_or_not_expired

  belongs_to :user, touch: true
  has_many :payments, -> { order(created_at: :desc) }, as: :payable, dependent: :destroy

  before_create :generate_uuid

  broadcasts_refreshes

  scope :should_be_expired, -> {
    where(status: 'Active').where('end_date < ?', Date.current)
  }
  scope :should_be_renewed, -> {
    where(status: 'Active').where(auto_renew: true).where(end_date: Date.current + 1.day)
  }

  #: -> bool
  def active?
    status == 'Active'
  end

  #: -> bool
  def auto_renew?
    auto_renew #: as !nil
  end

  #: -> bool
  def can_retry_payment?
    payments.all?(&:retryable?)
  end

  #: -> bool
  def can_extend_subscription?
    status == 'Active' && payments.exists? && payments.none?(&:awaiting?)
  end

  #: -> bool
  def extension_payment_failed?
    payment = payments.first
    payment&.simplified_state == :failure
  end

  #: -> void
  def extend_or_initialize_dates!
    if start_date.nil? || end_date.nil?
      self.start_date = Date.today
      self.end_date = 30.days.from_now.to_date
    else
      current_end_date = end_date #: as !nil
      self.end_date = current_end_date + 30.days
    end
    save!
  end

  #: -> void
  def renew
    @payment = ::Payment.create_with(payable: self).first #: ::Payment?
    return unless @payment
    return unless user&.primary_payment_method?

    # @payment.process_payment(
    #   cof:       'recurring',
    #   client_id: user&.primary_payment_method&.client_id,
    # )

    nil
  end

  #: -> BigDecimal
  def amount
    price
  end

  private

  #: -> void
  def auto_renew_requires_primary_payment_method
    return if user&.primary_payment_method? || user&.auto_renew_subscription?

    errors.add(:base, "Cannot enable auto-renew for this subscription: user doesn't have primary payment method")
  end

  #: -> void
  def cannot_have_dates_when_not_active_or_not_expired
    return if %w[Active Expired].include?(status)

    return unless start_date.present? || end_date.present?

    errors.add(:base, 'Start and end dates are only allowed for active or expired subscriptions')

  end

  #: -> void
  def generate_subscription_uuid
    self.uuid = "sub_#{SecureRandom.uuid}"
  end


end
