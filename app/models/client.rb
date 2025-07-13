# frozen_string_literal: true
# typed: strict

class Client < ApplicationRecord
  belongs_to :user,  touch: true
  has_many :payments, -> { order(created_at: :desc) }, dependent: :destroy
  has_many :payable_payments, -> {
    order(created_at: :desc)
  }, as: :payable, class_name: 'Payment', dependent: :destroy

  before_create :generate_client_number

  validate :prevent_duplicate_primary
  validate :ensure_primary_is_mit
  validate :prevent_auto_renew_subscription_with_no_primary

  validates :client_id, presence: true, uniqueness: true

  broadcasts_refreshes

  scope :cit, -> { where(status: %w[CIT MIT]) }
  scope :mit, -> { where(status: 'MIT') }

  #: -> bool
  def cit?
    status == 'CIT'
  end

  #: -> bool
  def mit?
    status == 'MIT'
  end

  # this is needed for payment of value 0.01 in order to authorize card for MIT payments
  #: -> BigDecimal
  def amount
    BigDecimal('0.01')
  end

  private

  #: -> void
  def generate_client_number
    self.client_number = SecureRandom.hex(10).upcase
  end

  #: -> void
  def prevent_duplicate_primary
    return unless primary? && user&.primary_payment_method?

    errors.add(:base, 'This user already has a primary Client')
  end

  #: -> void
  def ensure_primary_is_mit
    return unless primary? && status != 'MIT'

    errors.add(:base, 'Client must have status MIT to be primary')
  end

  #: -> voidś
  def prevent_auto_renew_subscription_with_no_primary
    return unless !primary? && user&.auto_renew_subscription?

    errors.add(:base, 'Cannot remove primary payment method with auto-renew subscription')
  end
end
