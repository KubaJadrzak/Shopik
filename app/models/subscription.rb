# frozen_string_literal: true
# typed: strict

class Subscription < ApplicationRecord
  validates :price, presence: true

  belongs_to :user, touch: true
  has_many :payments, -> { order(created_at: :desc) }, as: :payable, dependent: :destroy

  before_create :generate_uuid

  broadcasts_refreshes

  scope :should_be_expired, -> {
    where(state: 'Active').where('end_date < ?', Date.current)
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
  def generate_uuid
    self.uuid = "sub_#{SecureRandom.uuid}"
  end
end
