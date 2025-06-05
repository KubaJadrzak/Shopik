class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :espago_client
  has_many :charges, dependent: :destroy
end
