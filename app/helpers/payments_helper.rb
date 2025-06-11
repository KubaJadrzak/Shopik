module PaymentsHelper
  def payment_status_icon(payment_status)
    case payment_status
    when 'executed'
      icon = '✓'
      color_class = 'text-success'
    when 'refunded'
      icon = '✗'
      color_class = 'text-warning'
    when 'preauthorized', 'tds2_challenge', 'tds_redirected', 'dcc_decision', 'blik_redirected', 'transfer_redirected', 'new'
      icon = '–'
      color_class = 'text-primary'
    else
      icon = '✗'
      color_class = 'text-danger'
    end

    "<span class='#{color_class} fs-4'>#{icon}</span>".html_safe
  end
end
