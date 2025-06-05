class EspagoClient < ApplicationRecord
  belongs_to :user
  has_many :subscriptions, dependent: :destroy

  validates :client_id, presence: true, uniqueness: true
end
