# typed: strict

class User < ApplicationRecord
  extend T::Sig

  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :cart, dependent: :destroy
  has_many :rubits, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_rubits, through: :likes, source: :rubit
  has_many :orders, dependent: :destroy
  has_many :clients, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  has_many :order_payments, through: :orders, source: :payments
  has_many :subscription_payments, through: :subscriptions, source: :payments

  broadcasts_refreshes

  sig { returns(T::Boolean) }
  def active_subscription?
    subscriptions.where(status: 'Active').exists?
  end

  sig { returns(T.nilable(Subscription)) }
  def active_subscription
    subscriptions.find_by(status: 'Active')
  end

  sig { returns(T::Boolean) }
  def pending_subscription?
    subscriptions.where.not(status: %w[Active Expired]).exists?
  end

  sig { returns(T.nilable(Subscription)) }
  def pending_subscription
    subscriptions.where.not(status: %w[Active Expired]).first
  end

  sig { returns(T::Boolean) }
  def active_or_pending_subscription?
    subscriptions.where.not(status: 'Expired').exists?
  end

  #: -> bool
  def primary_payment_method?
    clients.where(primary: true).exists?
  end

  #: -> bool
  def mit_payment_method?
    clients.where(status: 'MIT').exists?
  end

  sig { returns(ActiveRecord::Relation) }
  def payments
    Payment.where(id: order_payments.select(:id))
           .or(Payment.where(id: subscription_payments.select(:id)))
  end
end
