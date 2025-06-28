# frozen_string_literal: true
# typed: strict

class Subscription < ApplicationRecord

  validates :price, presence: true

  belongs_to :user, touch: true
  has_many :payments, -> { order(created_at: :desc) }, as: :payable, dependent: :destroy

  before_create :generate_subscription_number

  broadcasts_refreshes

  scope :should_be_expired, -> {
    where(status: 'Active').where('end_date < ?', Date.current)
  }

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

  #: -> BigDecimal
  def amount
    price
  end

  private

  #: -> void
  def generate_subscription_number
    self.subscription_number = SecureRandom.hex(10).upcase
  end
end
