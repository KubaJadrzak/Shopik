# frozen_string_literal: true

module ClientsHelper
  def client_status_badge_class(status)
    case status
    when 'unverified'
      'bg-danger'
    when 'CIT', 'MIT'
      'bg-success'
    else
      'bg-secondary'
    end
  end

  def client_status_label(status)
    case status
    when 'unverified'
      'Unverified'
    when 'CIT', 'MIT'
      'Active'
    else
      status.titleize
    end
  end
end
