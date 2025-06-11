# typed: strict

class Subscription < ApplicationRecord
  extend T::Sig

  validates :price, presence: true

  belongs_to :user, touch: true
  has_many :payments, -> { order(created_at: :desc) }, as: :payable, dependent: :destroy

  before_create :generate_subscription_number
  broadcasts_refreshes

  scope :should_be_expired, -> {
    where(status: 'Active').where('end_date < ?', Date.current)
  }

  sig { returns(T::Boolean) }
  def can_retry_payment?
    payments.all?(&:retryable?)
  end

  sig { returns(T::Boolean) }
  def can_extend_subscription?
    status == 'Active' && payments.none?(&:awaiting?)
  end

  sig { returns(T::Boolean) }
  def extension_payment_failed?
    payment = payments.first
    payment&.simplified_state == :failure
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

  sig { returns(BigDecimal) }
  def amount
    price
  end

  private

  sig { void }
  def generate_subscription_number
    self.subscription_number = SecureRandom.hex(10).upcase
  end
end
