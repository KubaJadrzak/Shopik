# typed: strict

class Espago::SecureWebPageService
  extend T::Sig

  sig { params(order: Order).void }
  def initialize(order)
    @order = order
  end

  sig { returns(Espago::Response) }
  def create_payment
    app_host = T.let(ENV.fetch('APP_HOST_URL'), String)
    session_id = T.let(SecureRandom.hex(16), String)
    amount = T.let(@order.total_price, BigDecimal)
    ts = T.let(Time.now.to_i, Integer)

    checksum = generate_checksum(
      kind:       'sale',
      session_id: session_id,
      amount:     amount,
      currency:   'PLN',
      ts:         ts,
    )

    Espago::ClientService.new.send(
      'api/secure_web_page_register',
      method: :post,
      body:   {
        amount:       amount,
        currency:     'PLN',
        description:  "Payment for Order ##{@order.order_number}",
        kind:         'sale',
        session_id:   session_id,
        title:        "Order ##{@order.order_number}",
        checksum:     checksum,
        positive_url: "#{app_host}/espago/secure_web_page/payments/success?order_number=#{@order.order_number}",
        negative_url: "#{app_host}/espago/secure_web_page/payments/failure?order_number=#{@order.order_number}",
      },
    )
  end

  sig do
    params(
      kind:       String,
      session_id: String,
      amount:     BigDecimal,
      currency:   String,
      ts:         Integer,
    ).returns(String)
  end
  def generate_checksum(kind:, session_id:, amount:, currency:, ts:)
    app_id = T.let(Rails.application.credentials.dig(:espago, :app_id), String)
    checksum_key = T.let(Rails.application.credentials.dig(:espago, :checksum_key), String)

    raw_string = "#{app_id}#{kind}#{session_id}#{amount}#{currency}#{ts}#{checksum_key}"
    Digest::MD5.hexdigest(raw_string)
  end
end
