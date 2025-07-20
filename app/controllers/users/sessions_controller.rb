# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  if Rails.env.test? || Rails.env.development?
    skip_before_action :verify_authenticity_token

    def sign_in_before_test
      user = User.first

      if user
        sign_in(user)
        render json: { message: 'Signed in for test', email: user.email }, status: :ok
      else
        render json: { error: 'No user found' }, status: :not_found
      end
    end
  end
end
