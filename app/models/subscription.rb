# frozen_string_literal: true
# typed: strict

class Subscription < ApplicationRecord

  validates :price, presence: true

  validate :auto_renew_requires_primary_payment_method, if: :will_save_change_to_auto_renew?

  belongs_to :user, touch: true
  has_many :payments, -> { order(created_at: :desc) }, as: :payable, dependent: :destroy

  before_create :generate_subscription_number

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
    auto_renew
  end

  #: -> bool
  def can_retry_payment?
    payments.all?(&:retryable?)
  end

  #: -> bool
  def can_extend_subscription?
    status == 'Active' && payments.none?(&:awaiting?)
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
    @payment = ::Payment.create_payment(payable: self) #: ::Payment?

    return unless @payment
    return unless user&.primary_payment_method?

    @payment.process_payment(
      cof:       'recurring',
      client_id: user&.primary_payment_method&.client_id,
    )

    nil
  end

  #: -> BigDecimal
  def amount
    price
  end

  private

  #: -> void
  def auto_renew_requires_primary_payment_method
    owner = user #: as !nil
    return if owner.primary_payment_method? || active?

    errors.add(:base, "Cannot enable auto-renew for this subscription: user doesn't have primary payment method")
  end

  #: -> void
  def generate_subscription_number
    self.subscription_number = SecureRandom.hex(10).upcase
  end


end
