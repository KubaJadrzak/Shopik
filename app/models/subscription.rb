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
  scope :should_be_renewed, -> {
    where(state: 'Active').where(auto_renew: true).where(end_date: Date.current + 1.day)
  }

  #: -> bool
  def active?
    state == 'Active'
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
    state == 'Active' && payments.exists? && payments.none?(&:awaiting?)
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
  def generate_subscription_uuid
    self.uuid = "sub_#{SecureRandom.uuid}"
  end


end
