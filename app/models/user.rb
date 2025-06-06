class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_one :cart, dependent: :destroy
  has_many :rubits, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_rubits, through: :likes, source: :rubit
  has_many :orders, dependent: :destroy
  has_many :espago_clients, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  broadcasts_refreshes

  def has_active_subscription?
    subscriptions
      .joins(:charges)
      .where(charges: { state: 'executed' })
      .where('start_date <= ? AND end_date >= ?', Date.today, Date.today)
      .exists?
  end

end
