# typed:strict

class Client < ApplicationRecord
  extend T::Sig
  belongs_to :user
  has_many :payments, as: :payable, dependent: :destroy
  has_many :payments, dependent: :destroy
  has_many :payable_payments, as: :payable, class_name: 'Payment', dependent: :destroy

  before_create :generate_client_number

  validates :client_id, presence: true, uniqueness: true

  scope :cit, -> { where(status: 'CIT') }

  scope :mit, -> { where(status: 'MIT') }
  private

  sig { void }
  def generate_client_number
    self.client_number = SecureRandom.hex(10).upcase
  end
end
