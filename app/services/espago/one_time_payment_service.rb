# typed: strict

class Espago::OneTimePaymentService
  extend T::Sig

  sig { params(card_token: String, order: Order).void }
  def initialize(card_token:, order:)
    @card_token = card_token
    @order = order

  end

  sig { returns(Espago::Response) }
  def create_payment
    app_host = T.let(ENV.fetch('APP_HOST_URL'), String)
    Espago::ClientService.new.send(
      'api/charges',
      method: :post,
      body:   {
        amount:       @order.total_price,
        currency:     'pln',
        card:         @card_token,
        description:  "Payment for Order ##{@order.order_number}",
        positive_url: "#{app_host}/espago/payments/success?order_number=#{@order.order_number}",
        negative_url: "#{app_host}/espago/payments/failure?order_number=#{@order.order_number}",
      },
    )
  end
end
