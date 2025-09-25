# frozen_string_literal: true

module PaymentsHelper
  def payment_status_icon(simplified_state)
    case simplified_state
    when :success
      icon = '✓'
      color_class = 'text-success'
    when :pending || :uncertain
      icon = 'O'
      color_class = 'text-warning'
    else
      icon = '✗'
      color_class = 'text-danger'
    end

    "<span class='#{color_class} fs-2'>#{icon}</span>".html_safe
  end
end
