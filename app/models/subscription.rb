class Subscription < ApplicationRecord
  belongs_to :user, touch: true
  belongs_to :espago_client, optional: true
  has_many :charges, dependent: :destroy

  before_validation :set_default_dates, on: :create
  before_validation :set_price, on: :create

  before_create :generate_subscription_number

  broadcasts_refreshes

  def refresh_status!
    if currently_active?
      update!(status: :active)
    elsif end_date < Date.today
      update!(status: :expired)
    else
      update!(status: :paid)
    end
  end

  private

  def set_default_dates
    self.start_date ||= Date.today
    self.end_date   ||= 30.days.from_now.to_date
  end

  def set_price
    self.price ||= 4.99
  end

  def generate_subscription_number
    self.subscription_number = SecureRandom.hex(10).upcase
  end

end
