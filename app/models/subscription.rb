# frozen_string_literal: true
# typed: strict

class Subscription < ApplicationRecord
  validates :price, presence: true

  belongs_to :user, touch: true
  has_many :payments, -> { order(created_at: :desc) }, as: :payable, dependent: :destroy

  before_create :generate_uuid
  before_save :set_active_dates

  broadcasts_refreshes

  scope :should_be_expired, -> {
    where(state: 'Active').where('end_date < ?', Date.current)
  }

  scope :should_be_renewed, -> {
    joins(:user)
      .where(users: { auto_renew: true })
      .where(state: 'Expired')
  }

  #: -> String
  def to_param
    uuid
  end

  #: -> String?
  def last_payment_state
    payments.first&.state
  end

  #: -> ::Payment?
  def last_payment
    payments.first
  end

  #: -> bool
  def active?
    state == 'Active'
  end

  #: -> bool
  def can_retry_payment?
    payments.all?(&:retryable?)
  end

  #: -> BigDecimal
  def amount
    price
  end

  private

  #: -> void
  def set_active_dates
    return unless will_save_change_to_state? && state == 'Active'

    self.start_date ||= Date.current
    self.end_date   ||= Date.current + 1.month
  end

  #: -> void
  def generate_uuid
    self.uuid = "sub_#{SecureRandom.uuid}"
  end
end
