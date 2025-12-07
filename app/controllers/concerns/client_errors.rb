# typed: true
# frozen_string_literal: true

module ClientErrors
  include Kernel
  extend ActiveSupport::Concern


  def client_error!(message = 'We are experiencing an issue with your client!')
    raise ClientErrors, message
  end
end
