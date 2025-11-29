# typed: strict
# frozen_string_literal: true

STATUS_MAP = {
  'rejected'            => 'Payment Rejected',
  'failed'              => 'Payment Failed',
  'resigned'            => 'Payment Resigned',
  'reversed'            => 'Cancelled',
  'preauthorized'       => 'Payment in Progress',
  'tds2_challenge'      => 'Payment in Progress',
  'tds_redirected'      => 'Payment in Progress',
  'dcc_decision'        => 'Payment in Progress',
  'blik_redirected'     => 'Payment in Progress',
  'transfer_redirected' => 'Payment in Progress',
  'new'                 => 'Payment in Progress',
  'refunded'            => 'Returned',
  'server_error'        => 'Payment Error',
  'timeout'             => 'Payment Error',
  'connection_failed'   => 'Payment Error',
  'ssl_error'           => 'Payment Error',
  'parsing_error'       => 'Payment Error',
  'invalid_uri'         => 'Payment Error',
  'unexpected_error'    => 'Payment Error',
  'client_error'        => 'Payment Error',
}.freeze #: Hash[String, String]

ORDER_STATUS_MAP = STATUS_MAP.merge('executed'  => 'Preparing for Shipment',
                                    'finalized' => 'Delivered',) #: Hash[String, String]

SUBSCRIPTION_STATUS_MAP = STATUS_MAP.merge('executed'  => 'Active',
                                           'finalized' => 'Active',) #: Hash[String, String]

SUCCESS_STATUSES = %w[executed
                      finalized
                      refund
                      reverse].freeze #: Array[String]

REJECTED_STATUSES = %w[
  rejected
  failed
  resigned
].freeze #: Array[String]

PENDING_STATUSES = %w[
  preauthorized
  tds2_challenge
  tds_redirected
  dcc_decision
  blik_redirected
  transfer_redirected
  new
].freeze #: Array[String]

UNCERTAIN_STATUSES = %w[
  server_error
  timeout
  connection_failed
  ssl_error
  parsing_error
  invalid_uri
  unexpected_error
].freeze #: Array[String]

FAILURE_STATUSES = %w[
  client_error
].freeze

AWAITING_STATUSES = (PENDING_STATUSES + UNCERTAIN_STATUSES).freeze #: Array[String]
REJECTED_OR_UNCERTAIN_STATUSES = (REJECTED_STATUSES + UNCERTAIN_STATUSES).freeze #: Array[String]
