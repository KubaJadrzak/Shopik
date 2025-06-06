class EspagoClient < ApplicationRecord
  belongs_to :user
  has_many :subscriptions, dependent: :destroy

  before_create :generate_client_number

  validates :client_id, presence: true, uniqueness: true

  private

  def generate_client_number
    self.client_number = SecureRandom.hex(10).upcase
  end
end
