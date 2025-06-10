module SubscriptionsHelper
  def color_for_status(status)
    case status
    when 'Active'
      'bg-success'
    when 'Payment Rejected', 'Payment Failed', 'Payment Resigned', 'Payment Reversed', 'Payment Error'
      'bg-danger'
    when 'Payment Refunded'
      'bg-warning'
    when 'Waiting for Payment', 'New'
      'bg-primary'
    else
      'bg-secondary'
    end
  end
end
