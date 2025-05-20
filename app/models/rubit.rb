# typed: strict

class Rubit < ApplicationRecord
  belongs_to :user
  belongs_to :parent_rubit, class_name: 'Rubit', optional: true

  has_many :likes, dependent: :destroy
  has_many :likes_by_users, through: :likes, source: :user
  has_many :child_rubits, class_name: 'Rubit', foreign_key: 'parent_rubit_id', dependent: :destroy

  validates :content, presence: true, length: { maximum: 128 }

  scope :root_rubits, -> { where(parent_rubit_id: nil) }
  scope :child_rubits, -> { where.not(parent_rubit_id: nil) }
end
