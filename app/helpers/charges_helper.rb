module ChargesHelper
  def color_for_charge_status(charge_status)
    case charge_status
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
