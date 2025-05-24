module OrdersHelper
  def payment_status_badge_class(status)
    case status
    when 'executed'
      'bg-success'
    when 'rejected', 'failed', 'resigned', 'reversed'
      'bg-danger'
    when 'preauthorized', 'tds2_challenge', 'tds_redirected', 'dcc_decision', 'blik_redirected', 'transfer_redirected', 'new'
      'bg-warning text-dark'
    when 'refunded'
      'bg-info'
    else
      'bg-secondary'
    end
  end
end
