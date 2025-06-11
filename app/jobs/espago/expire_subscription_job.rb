require 'sidekiq-scheduler'

class Espago::ExpireSubscriptionJob < ApplicationJob
  extend T::Sig
  queue_as :default

  def perform
    Subscription.should_be_expired.find_each do |subscription|
      subscription.update!(status: 'Expired')
    end
  end
end
