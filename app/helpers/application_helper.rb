# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def status_color(state)
    if SUCCESS_STATUSES.include?(state)
      'bg-success'
    elsif REJECTED_STATUSES.include?(state)
      'bg-danger'
    elsif AWAITING_STATUSES.include?(state)
      'bg-warning'
    else
      'bg-secondary'
    end
  end
end
