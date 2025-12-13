# typed: true
# frozen_string_literal: true

module GenericErrors
  include Kernel
  extend ActiveSupport::Concern


  def generic_error!(message = 'We are experiencing an issue with your request!')
    raise GenericError, message
  end
end
