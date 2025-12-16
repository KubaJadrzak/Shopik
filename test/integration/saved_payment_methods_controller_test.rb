# frozen_string_literal: true

require 'test_helper'
require 'vcr'

class SavedPaymentMethodsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = FactoryBot.create(:user)
    sign_in @user
  end


  test 'AUTHORIZE should authorize Saved Payment Method' do
    saved_payment_method = FactoryBot.create(:saved_payment_method, user: @user, espago_client_id: 'cli_9d0KbF38qp7MlxXu', state: 'CIT Verified')
    VCR.use_cassette('AUTHORIZE should authorize Saved Payment Method') do
      post authorize_saved_payment_method_path(saved_payment_method)
    end

    assert_requested(:post, 'https://sandbox.espago.com/api/clients/cli_9d0KbF38qp7MlxXu/authorize', times: 1)

    assert_response :redirect
    assert_includes response.location, 'http://www.example.com/saved_payment_methods/sav_'

    saved_payment_method.reload
    assert_equal 'MIT Verified', saved_payment_method.state
  end

  test 'AUTHORIZE should raise redirect_to account_path and show alert when saved_payment_method cannot be MIT verified' do
    saved_payment_method = FactoryBot.create(:saved_payment_method, user: @user, espago_client_id: 'cli_9d0KbF38qp7MlxXu', state: 'MIT Verified')
    post authorize_saved_payment_method_path(saved_payment_method)

    assert_redirected_to account_path
    assert_equal 'We are experiencing an issue with your Saved Payment Method!', flash[:alert]
  end

  test 'TOGGLE_PRIMARY should toggle primary from true to false' do
    saved_payment_method = FactoryBot.create(:saved_payment_method, user: @user, primary: true, state: 'MIT Verified')
    patch toggle_primary_saved_payment_method_path(saved_payment_method)

    saved_payment_method.reload
    assert_equal false, saved_payment_method.primary
  end

  test 'TOGGLE_PRIMARY should toggle primary from false to true' do
    saved_payment_method = FactoryBot.create(:saved_payment_method, user: @user, primary: false, state: 'MIT Verified')
    patch toggle_primary_saved_payment_method_path(saved_payment_method)

    saved_payment_method.reload
    assert_equal true, saved_payment_method.primary
  end

  test 'TOGGLE_PRIMARY should disable auto_renew if toggle primary from true to false' do
    saved_payment_method = FactoryBot.create(:saved_payment_method, user: @user, primary: true, state: 'MIT Verified')
    @user.auto_renew = true
    @user.save

    patch toggle_primary_saved_payment_method_path(saved_payment_method)

    saved_payment_method.reload
    @user.reload

    assert_equal false, saved_payment_method.primary
    assert_equal false, @user.auto_renew
  end

  test 'TOGGLE_PRIMARY should switch primary between saved payment methods' do
    saved_payment_method_first = FactoryBot.create(:saved_payment_method, user: @user, primary: true, state: 'MIT Verified')
    saved_payment_method_second = FactoryBot.create(:saved_payment_method, user: @user, primary: false, state: 'MIT Verified')

    patch toggle_primary_saved_payment_method_path(saved_payment_method_second)

    saved_payment_method_first.reload
    saved_payment_method_second.reload

    assert_equal false, saved_payment_method_first.primary
    assert_equal true, saved_payment_method_second.primary
  end

  test 'TOGGLE_PRIMARY should preserve auto_renew when switching primary between saved payment methods' do
    saved_payment_method_first = FactoryBot.create(:saved_payment_method, user: @user, primary: true, state: 'MIT Verified')
    saved_payment_method_second = FactoryBot.create(:saved_payment_method, user: @user, primary: false, state: 'MIT Verified')
    @user.auto_renew = true
    @user.save


    patch toggle_primary_saved_payment_method_path(saved_payment_method_second)

    saved_payment_method_first.reload
    saved_payment_method_second.reload
    @user.reload

    assert_equal false, saved_payment_method_first.primary
    assert_equal true, saved_payment_method_second.primary
    assert_equal true, @user.auto_renew
  end

end
