# frozen_string_literal: true

module OrdersHelper
  def order_status_color(state)
    case state
    when SUCCESS_STATUSES.include?(state)
      'bg-success'
    when REJECTED_STATUSES.include?(state)
      'bg-danger'
    when AWAITING_STATUSES.include?(state)
      'bg-warning'
    else
      'bg-secondary'
    end
  end
end
