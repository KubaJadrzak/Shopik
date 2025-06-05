class Charge < ApplicationRecord
  belongs_to :subscription
  delegate :espago_client, to: :subscription
end
