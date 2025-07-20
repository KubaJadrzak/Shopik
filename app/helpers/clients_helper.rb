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

  def client_status_icon(status)
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
