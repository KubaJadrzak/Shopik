# frozen_string_literal: true

# this fix was implemented since sidekiq didn't work with turbo 8 broadcasts_refreshes properly
Rails.application.config.after_initialize do
  Turbo::Streams::BroadcastStreamJob.class_eval do
    self.queue_adapter = :async
  end
end
