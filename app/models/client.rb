# frozen_string_literal: true
# typed: strict

class Client < ApplicationRecord
  belongs_to :user,  touch: true
  has_many :payments, -> { order(created_at: :desc) }, dependent: :destroy

  before_create :generate_uuid

  validate :prevent_duplicate_primary
  validate :ensure_primary_is_mit
  validate :prevent_auto_renew_subscription_with_no_primary, if: :will_save_change_to_primary?


  broadcasts_refreshes

  scope :cit, -> { where(state: %w[CIT MIT]) }
  scope :mit, -> { where(state: 'MIT') }

  #: -> bool
  def cit?
    state == 'CIT'
  end

  #: -> bool
  def mit?
    state == 'MIT'
  end

  # this is needed for payment of value 0.01 in order to authorize card for MIT payments
  #: -> BigDecimal
  def amount
    BigDecimal('0.01')
  end

  private

  #: -> void
  def generate_uuid
    self.uuid = "car_#{SecureRandom.uuid}"
  end

  #: -> void
  def prevent_duplicate_primary
    return unless primary? && user&.primary_payment_method?

    errors.add(:base, 'This user already has a primary Client')
  end

  #: -> void
  def ensure_primary_is_mit
    return unless primary? && state != 'MIT'

    errors.add(:base, 'Client must have state MIT to be primary')
  end

  #: -> void
  def prevent_auto_renew_subscription_with_no_primary
    owner = user #: as !nil
    return unless owner.primary_payment_method? && owner.auto_renew_subscription?

    errors.add(:base, 'Cannot remove primary payment method with auto-renew subscription')
  end
end
