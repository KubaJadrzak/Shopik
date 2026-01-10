# frozen_string_literal: true

FactoryBot.define do
  factory :saved_payment_method do
    association :user
    state { 'MIT Verified' }
    last4 { '0006' }
    first_name { 'John ' }
    last_name { 'Doe' }
    espago_client_id { 'cli_9d05-phkJnJOajc0' }
    card_identifier { 'cid_9cfzW0qxuoyOOi5h' }
    year { 2028 }
    month { 1 }
    primary { false }
    company { 'VI' }
  end
end
