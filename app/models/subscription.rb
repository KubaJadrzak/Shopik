# typed: strict

class Subscription < ApplicationRecord
  extend T::Sig

  belongs_to :user, touch: true
  belongs_to :espago_client, optional: true
  has_many :payments, dependent: :destroy

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
  def can_extend_subscription?
    status == 'Active' && !in_progress_payment?
  end

  sig { returns(T::Boolean) }
  def can_retry_payment?
    payments.all?(&:retryable?)
  end
  sig { returns(T::Boolean) }
  def last_extension_payment_failed?
    last_payment = payments.order(created_at: :desc).first
    last_payment.present? && last_payment.simplified_status == :failure
  end

  sig { void }
  def extend_or_initialize_dates!
    if start_date.nil? || end_date.nil?
      self.start_date = Date.today
      self.end_date = 30.days.from_now.to_date
    else
      self.end_date = end_date + 30.days
    end
    save!
  end


  private


  sig { void }
  def set_price
    self.price ||= BigDecimal('4.99')
  end

  sig { void }
  def generate_subscription_number
    self.subscription_number = SecureRandom.hex(10).upcase
  end
end
