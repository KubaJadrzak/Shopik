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

  has_many :order_payments, through: :orders, source: :payments
  has_many :subscription_payments, through: :subscriptions, source: :payments

  broadcasts_refreshes

  def orders_with_in_progress_payments
    orders.joins(:payments).merge(Payment.in_progress).distinct
  end

  def subscriptions_with_in_progress_payments
    subscriptions.joins(:payments).merge(Payment.in_progress).distinct
  end

  def has_active_subscription?
    subscriptions
      .joins(:payments)
      .where(payments: { state: 'executed' })
      .where('start_date <= ? AND end_date >= ?', Date.today, Date.today)
      .exists?
  end

  def payments
    Payment.where(id: order_payments.select(:id))
           .or(Payment.where(id: subscription_payments.select(:id)))
  end

end
