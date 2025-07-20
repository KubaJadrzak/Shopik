module OrdersHelper
  def order_color_for_status(status)
    case status
    when 'Preparing for Shipment'
      'bg-success'
    when 'Payment Rejected', 'Payment Failed', 'Payment Resigned', 'Payment Reversed', 'Payment Refunded', 'Payment Error'
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
