# frozen_string_literal: true

module OrderErrors
  include Kernel
  extend ActiveSupport::Concern


  def order_error!(message = 'We are experiencing an issue with your Order!')
    raise OrderError, message
  end
end
