# frozen_string_literal: true
# typed: strict

class User < ApplicationRecord

  # Devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :cart, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :saved_payment_methods, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  has_many :order_payments, through: :orders, source: :payments
  has_many :subscription_payments, through: :subscriptions, source: :payments

  delegate :cart_items, to: :cart

  broadcasts_refreshes

  scope :should_renew_subscription, -> {
    joins(:subscriptions)
      .where(auto_renew: true)
      .where(subscriptions: { state: 'Expired' })
      .where(
        subscriptions: {
          id: Subscription
                .select('id')
                .where('subscriptions.user_id = users.id')
                .order(id: :desc)
                .limit(1),
        },
      )
  }


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
    mit_payment_method?.where(primary: true).exists?
  end

  #: -> ::SavedPaymentMethod?
  def primary_payment_method
    mit_payment_method?.find_by(primary: true)
  end

  #: -> bool
  def can_toggle_auto_renew?
    primary_payment_method? && subscriptions.exists?
  end

  #: -> bool
  def mit_payment_method?
    mit_payment_method?.where(state: 'MIT').exists?
  end

  #: -> ActiveRecord::Relation
  def payments
    Payment.where(id: order_payments.select(:id)).or(Payment.where(id: subscription_payments.select(:id)))
  end

  #: -> BigDecimal
  def cart_quantity
    cart_items.sum(:quantity)
  end
end
