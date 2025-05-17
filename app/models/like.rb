class Like < ApplicationRecord
  belongs_to :rubit, counter_cache: true
  belongs_to :user

  validates :user_id, uniqueness: { scope: :rubit_id, message: 'this rubbit was already liked' }
end
