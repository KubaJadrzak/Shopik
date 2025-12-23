# frozen_string_literal: true
# typed: false

VCR.eject_cassette if VCR.current_cassette
VCR.turn_off!
WebMock.disable! if defined?(WebMock)

if defined?(DatabaseCleaner)
  # cleaning the database using database_cleaner
  DatabaseCleaner.strategy = :truncation
  DatabaseCleaner.clean
else
  logger.warn 'add database_cleaner or update cypress/app_commands/clean.rb'
end

CypressOnRails::SmartFactoryWrapper.reload

Rails.logger.info 'APPCLEANED' # used by log_fail.rb
