# frozen_string_literal: true
# typed:strict

class Client < ApplicationRecord
  extend T::Sig
  belongs_to :user,  touch: true
  has_many :payments, -> { order(created_at: :desc) }, dependent: :destroy
  has_many :payable_payments, -> { order(created_at: :desc) }, as: :payable, class_name: 'Payment', dependent: :destroy

  before_create :generate_client_number

  validates :client_id, presence: true, uniqueness: true

  broadcasts_refreshes

  scope :cit, -> { where(status: %w[CIT MIT]) }

  scope :mit, -> { where(status: 'MIT') }

  # this is needed for payment of value 0.01 in order to authorize card for MIT payments
  sig { returns(BigDecimal) }
  def amount
    BigDecimal('0.01')
  end

  private

  sig { void }
  def generate_client_number
    self.client_number = SecureRandom.hex(10).upcase
  end
end
