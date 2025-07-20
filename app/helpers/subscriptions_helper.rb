module SubscriptionsHelper
  def subscription_color_for_status(status)
    case status
    when 'Active'
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

  def subscription_status_icon(status)
    icon, color_class = case status
                        when 'Yes'
                          ['✓', 'text-success']
                        when 'No'
                          ['✗', 'text-danger']
                        end

    content_tag(:span, icon,
                class: color_class.to_s,
                style: 'font-size: 1.5rem; margin: 0; padding: 0; line-height: 1; vertical-align: middle;',)
  end

end
