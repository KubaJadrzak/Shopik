FactoryBot.define do
  factory :saved_payment_method do
    association :user
    state { 'CIT Verified ' }
    last4 { '0006' }
    first_name { 'John ' }
    last_name { 'Doe' }
    espago_client_id { 'cli_9d05-phkJnJOajc0' } # this is a real espago_client_id
    card_identifier { 'cid_9cfzW0qxuoyOOi5h' } # this is a real card_identifier
    year { 2028 }
    month { 1 }
    primary { false }
    company { 'VI' }
  end
end
