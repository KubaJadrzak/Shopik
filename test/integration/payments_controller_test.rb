# frozen_string_literal: true

require 'test_helper'
require 'vcr'

class PaymentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = FactoryBot.create(:user, :with_order, :with_cit_saved_payment_method)
    @order = @user.orders.first
    sign_in @user
  end

  test 'CREATE should create secure web page payment when secure web page payment method' do
    VCR.use_cassette('CREATE should create secure web page payment when secure web page payment method') do
      post payments_path, params: {
        payable_number: @order.uuid,
        payment_method: 'secure_web_page',
      }
    end
    payment = ::Payment.first

    assert_requested(:post, 'https://sandbox.espago.com/api/secure_web_page_register', times: 1) do |req|
      body = JSON.parse(req.body)

      assert_equal '10.0', body['amount']
      assert_equal 'PLN', body['currency']
      assert_equal payment.uuid, body['description']
      assert body['positive_url'].end_with?('/success')
      assert body['negative_url'].end_with?('/rejected')
      assert_nil body['client']
      assert_nil body['cof']
    end

    assert_response :redirect
    assert_includes response.location, 'https://sandbox.espago.com/secure_web_page/pay_'

    assert_equal 'new', payment.state
    assert_equal 10.00, payment.amount
    assert_equal 'secure_web_page', payment.payment_method
    assert payment.espago_payment_id
    assert payment.espago_client_id
    assert payment.response
    assert_nil payment.cof
  end

  test 'CREATE should create iframe payment when iframe payment method' do
    VCR.use_cassette('CREATE should create iframe payment when iframe payment method') do
      espago_card_token = 'cc_9d0R4wtk6xkPEV67p' # if you rewrite cassette you will need to generate new espago_card_token
      post payments_path, params: {
        payable_number: @order.uuid,
        payment_method: 'iframe',
        card_token:     espago_card_token,
      }
    end
    payment = ::Payment.first

    assert_requested(:post, 'https://sandbox.espago.com/api/charges', times: 1) do |req|
      body = JSON.parse(req.body)

      assert_equal '10.0', body['amount']
      assert_equal 'PLN', body['currency']
      assert_equal payment.uuid, body['description']
      assert body['positive_url'].end_with?('/success')
      assert body['negative_url'].end_with?('/rejected')
      assert_nil body['client']
      assert_nil body['cof']
    end

    assert_response :redirect
    assert_includes response.location, 'https://sandbox.espago.com/secure_web_page/pay_'

    assert_equal 'new', payment.state
    assert_equal 10.00, payment.amount
    assert_equal 'iframe', payment.payment_method
    assert payment.espago_payment_id
    assert payment.espago_client_id
    assert payment.response
    assert_nil payment.cof
  end

  test 'CREATE should create cit payment when espago_client_id payment method' do
    saved_payment_method = @user.saved_payment_methods.first
    VCR.use_cassette('CREATE should create cit payment when espago_client_id payment method') do
      post payments_path, params: {
        payable_number: @order.uuid,
        payment_method: saved_payment_method.espago_client_id,
      }
    end
    payment = ::Payment.first

    assert_requested(:post, 'https://sandbox.espago.com/api/charges', times: 1) do |req|
      body = JSON.parse(req.body)

      assert_equal '10.0', body['amount']
      assert_equal 'PLN', body['currency']
      assert_equal payment.uuid, body['description']
      assert body['positive_url'].end_with?('/success')
      assert body['negative_url'].end_with?('/rejected')
      assert_equal saved_payment_method.espago_client_id, body['client']
      assert_nil body['cof']
    end

    assert_response :redirect
    assert_includes response.location, 'https://sandbox.espago.com/secure_web_page/pay_'

    assert_equal 'new', payment.state
    assert_equal 10.00, payment.amount
    assert_equal 'cit', payment.payment_method
    assert payment.espago_payment_id
    assert payment.espago_client_id
    assert payment.response
    assert_nil payment.cof
  end

  test 'CREATE should create storing payment when cof=storing' do
    VCR.use_cassette('CREATE should create storing payment when cof=storing') do
      post payments_path, params: {
        payable_number: @order.uuid,
        payment_method: 'secure_web_page',
        cof:            'storing',
      }
    end
    payment = ::Payment.first

    assert_requested(:post, 'https://sandbox.espago.com/api/secure_web_page_register', times: 1) do |req|
      body = JSON.parse(req.body)

      assert_equal '10.0', body['amount']
      assert_equal 'PLN', body['currency']
      assert_equal payment.uuid, body['description']
      assert body['positive_url'].end_with?('/success')
      assert body['negative_url'].end_with?('/rejected')
      assert_nil body['client']
      assert_equal 'storing', body['cof']
    end

    assert_response :redirect
    assert_includes response.location, 'https://sandbox.espago.com/secure_web_page/pay_'

    assert_equal 'new', payment.state
    assert_equal 10.00, payment.amount
    assert_equal 'secure_web_page', payment.payment_method
    assert payment.espago_payment_id
    assert payment.espago_client_id
    assert payment.response
    assert_equal 'storing', payment.cof
  end

  test 'CREATE should raise redirect_to account_path and show alert when payable_method not provided' do
    post payments_path, params: {
      payable_number: @order.uuid,
    }

    assert_redirected_to account_path
    assert_equal 'We are experiencing an issue with your payment!', flash[:alert]
  end

  test 'CREATE should raise redirect_to account_path and show alert when payment_number not provided' do
    post payments_path, params: {
      payment_method: 'secure_web_page',
    }

    assert_redirected_to account_path
    assert_equal 'We are experiencing an issue with your payment!', flash[:alert]
  end

  test 'REVERSE should reverse payment' do
    reversable_payment = FactoryBot.create(:payment, :reversable, payable: @order)
    VCR.use_cassette('REVERSE should reverse payment') do
      post reverse_payment_path(reversable_payment)
    end
    assert_response :redirect
    assert_includes response.location, 'http://www.example.com/orders/ord_'

    assert_requested(:delete, 'https://sandbox.espago.com/api/charges/pay_9d0MB60taOJrWmqn', times: 1)

    reversable_payment.reload
    assert_equal 'reversed', reversable_payment.state
  end

  test 'REVERSE should redirect_to account_path and show alert when payment is not reversable' do
    reversable_payment = FactoryBot.create(:payment, payable: @order)
    post reverse_payment_path(reversable_payment)

    assert_redirected_to account_path
    assert_equal 'We are experiencing an issue with your payment!', flash[:alert]
  end

  test 'REFUND should refund payment' do
    refundable_payment = FactoryBot.create(:payment, :refundable, payable: @order)
    VCR.use_cassette('REFUND should refund payment') do
      post refund_payment_path(refundable_payment)
    end

    assert_response :redirect
    assert_includes response.location, 'http://www.example.com/orders/ord_'

    assert_requested(:post, 'https://sandbox.espago.com/api/charges/pay_9d0qcbd9wGrf4WtM/refund', times: 1)

    refundable_payment.reload
    assert_equal 'refunded', refundable_payment.state
  end

  test 'REFUND should redirect_to account_path and show alert when payment is not refundable' do
    refundable_payment = FactoryBot.create(:payment, payable: @order)
    post reverse_payment_path(refundable_payment)

    assert_redirected_to account_path
    assert_equal 'We are experiencing an issue with your payment!', flash[:alert]
  end
end
