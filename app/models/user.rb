# frozen_string_literal: true
# typed: strict

class User < ApplicationRecord

  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :cart, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :clients, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  has_many :order_payments, through: :orders, source: :payments
  has_many :subscription_payments, through: :subscriptions, source: :payments

  delegate :cart_items, to: :cart

  broadcasts_refreshes

  #: -> bool
  def active_subscription?
    subscriptions.where(state: 'Active').exists?
  end

  #: -> Subscription?
  def active_subscription
    subscriptions.find_by(state: 'Active')
  end

  #: -> bool
  def auto_renew_subscription?
    subscriptions.where(auto_renew: true).exists?
  end

  #: -> Subscription?
  def auto_renew_subscription
    subscriptions.find_by(auto_renew: true)
  end

  #: -> bool
  def pending_subscription?
    subscriptions.where.not(state: %w[Active Expired]).exists?
  end

  #: -> Subscription?
  def pending_subscription
    subscriptions.where.not(state: %w[Active Expired]).first
  end

  #: -> bool
  def active_or_pending_subscription?
    subscriptions.where.not(state: 'Expired').exists?
  end

  #: -> bool
  def primary_payment_method?
    clients.where(primary: true).exists?
  end

  #: -> ::Client?
  def primary_payment_method
    clients.find_by(primary: true)
  end

  #: -> bool
  def mit_payment_method?
    clients.where(state: 'MIT').exists?
  end

  #: -> ActiveRecord::Relation
  def payments
    Payment.where(id: order_payments.select(:id))
           .or(Payment.where(id: subscription_payments.select(:id)))
  end

  #: -> BigDecimal
  def cart_quantity
    cart_items.sum(:quantity)
  end
end
