module PaymentsHelper
  def color_for_payment_status(payment_status)
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
