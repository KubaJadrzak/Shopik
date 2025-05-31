# typed: true
# frozen_string_literal: true

require "active_support/core_ext/integer/time"
require "bootsnap/setup"
require "bundler/setup"
require "devise/orm/active_record"
require "factory_bot"
require "pagy/extras/countless"
require "rails/all"
require "rails/test_help"
require "rspec/rails"
require "sidekiq/web"
require "webmock/rspec"
