# frozen_string_literal: true

module OrdersHelper
  def order_status_color(status)
    case status
    when 'Preparing for Shipment', 'Delivered'
      'bg-success'
    when 'Payment Rejected', 'Payment Failed', 'Payment Resigned', 'Payment Error'
      'bg-danger'
    when 'Waiting for Payment', 'Awaiting Payment'
      'bg-warning'
    when 'New'
      'bg-primary'
    else
      'bg-secondary'
    end
  end
end
