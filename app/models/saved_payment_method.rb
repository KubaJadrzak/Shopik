# frozen_string_literal: true
# typed: strict

class SavedPaymentMethod < ApplicationRecord
  belongs_to :user,  touch: true
  has_many :payments, -> { order(created_at: :desc) }, dependent: :nullify

  before_create :generate_uuid

  broadcasts_refreshes

  #: -> String
  def to_param
    uuid
  end

  #: -> bool
  def cit?
    state == 'CIT Verified'
  end

  #: -> bool
  def mit?
    state == 'MIT Verified'
  end

  private

  #: -> void
  def generate_uuid
    self.uuid = "sav_#{SecureRandom.uuid}"
  end
end
