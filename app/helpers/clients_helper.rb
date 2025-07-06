# frozen_string_literal: true

module ClientsHelper
  def client_status_badge(status)
    case status
    when 'CIT', 'MIT', 'primary'
      'bg-success'
    else
      'bg-danger'
    end
  end

  def client_status_label(status)
    case status
    when 'CIT', 'MIT'
      'Verified'
    else
      'Unverified'
    end
  end
end
