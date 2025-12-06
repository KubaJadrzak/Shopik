# frozen_string_literal: true
# typed: strict

class Client < ApplicationRecord
  belongs_to :user,  touch: true
  has_many :payments, -> { order(created_at: :desc) }, dependent: :destroy

  before_create :generate_uuid

  broadcasts_refreshes

  scope :cit, -> { where(state: %w[CIT MIT]) }
  scope :mit, -> { where(state: 'MIT') }

  #: -> String
  def to_param
    uuid
  end

  #: -> bool
  def cit?
    state == 'CIT'
  end

  #: -> bool
  def mit?
    state == 'MIT'
  end


  private

  #: -> void
  def generate_uuid
    self.uuid = "cli_#{SecureRandom.uuid}"
  end
end
