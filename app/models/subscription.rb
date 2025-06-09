# typed: strict

class Subscription < ApplicationRecord
  extend T::Sig

  belongs_to :user, touch: true
  belongs_to :espago_client, optional: true
  has_many :payments, dependent: :destroy

  before_validation :set_default_dates, on: :create
  before_validation :set_price, on: :create

  before_create :generate_subscription_number

  broadcasts_refreshes

  sig { returns(T.nilable(Payment)) }
  def in_progress_payment
    payments.in_progress.first
  end

  sig { returns(T::Boolean) }
  def in_progress_payment?
    in_progress_payment.present?
  end

  sig { returns(T::Boolean) }
  def can_retry_payment?
    payments.all?(&:retryable?)
  end

  private

  sig { void }
  def set_default_dates
    self.start_date = Date.today if start_date.nil?
    self.end_date = 30.days.from_now.to_date if end_date.nil?
  end

  sig { void }
  def set_price
    self.price ||= BigDecimal('4.99')
  end

  sig { void }
  def generate_subscription_number
    self.subscription_number = SecureRandom.hex(10).upcase
  end
end
