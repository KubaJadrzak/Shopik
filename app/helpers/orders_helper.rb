module OrdersHelper
  def badge_class_for_status(status)
    case status
    when 'Preparing for Shipment'
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

  def badge_class_for_payment_status(payment_status)
    case payment_status
    when 'executed'
      'bg-success'
    when 'refunded'
      'bg-warning'
    when 'preauthorized', 'tds2_challenge', 'tds_redirected', 'dcc_decision', 'blik_redirected', 'transfer_redirected', 'new'
      'bg-primary'
    else
      'bg-danger'
    end
  end
end
