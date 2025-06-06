class Charge < ApplicationRecord
  belongs_to :subscription
  delegate :espago_client, to: :subscription

  before_create :generate_charge_number

  scope :executed, -> { where(state: 'executed') }


  STATUS_MAP = T.let({
                       'executed'              => 'Payment Successful',
                       'rejected'              => 'Payment Rejected',
                       'failed'                => 'Payment Failed',
                       'resigned'              => 'Payment Resigned',
                       'reversed'              => 'Payment Reversed',
                       'preauthorized'         => 'Waiting for Payment',
                       'tds2_challenge'        => 'Waiting for Payment',
                       'tds_redirected'        => 'Waiting for Payment',
                       'dcc_decision'          => 'Waiting for Payment',
                       'blik_redirected'       => 'Waiting for Payment',
                       'transfer_redirected'   => 'Waiting for Payment',
                       'new'                   => 'Waiting for Payment',
                       'refunded'              => 'Payment Refunded',

                       'timeout'               => 'Awaiting Payment',
                       'connection_failed'     => 'Awaiting Payment',
                       'ssl_error'             => 'Awaiting Payment',
                       'parsing_error'         => 'Awaiting Payment',
                       'unknown_faraday_error' => 'Awaiting Payment',
                       'unexpected_error'      => 'Awaiting Payment',

                       'invalid_uri'           => 'Payment Error',
                     }, T::Hash[String, String],)

  def update_status_by_payment_status(state)
    self.state = state
    save!

    subscription_status = STATUS_MAP[state] || 'Unknown Status'

    subscription.status = subscription_status
    subscription.save!
  end

  private

  def generate_charge_number
    self.charge_number = SecureRandom.hex(10).upcase
  end
end
