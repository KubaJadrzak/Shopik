import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    amount: String
  }

  connect() {
    this.loadGooglePayApi()
      .then(() => this.onGooglePayLoaded())
      .catch(console.error)
  }

  async loadGooglePayApi() {
    if (window.google?.payments) return

    await new Promise((resolve, reject) => {
      const script = document.createElement("script")
      script.src = "https://pay.google.com/gp/p/js/pay.js"
      script.onload = resolve
      script.onerror = reject
      document.head.appendChild(script)
    })
  }

  get paymentsClient() {
    if (!this._paymentsClient) {
      this._paymentsClient = new google.payments.api.PaymentsClient({
        environment: "TEST",
      })
    }
    return this._paymentsClient
  }

  onGooglePayLoaded() {
    this.paymentsClient
      .isReadyToPay(this.isReadyToPayRequest())
      .then(response => {
        if (response.result) {
          this.addGooglePayButton()
        }
      })
  }

  addGooglePayButton() {
    const button = this.paymentsClient.createButton({
      onClick: () => this.onGooglePayButtonClicked(),
      buttonSizeMode: "fill",
    })

    this.element.appendChild(button)
  }

  onGooglePayButtonClicked() {
    this.paymentsClient
      .loadPaymentData(this.paymentDataRequest())
      .then(paymentData => this.processPayment(paymentData))
      .catch(console.error)
  }

  processPayment(paymentData) {
    const token =
      paymentData.paymentMethodData.tokenizationData.token

    console.log("Google Pay token:", token)

    const paymentInput = document.querySelector('input[name="payment_method"]')
    if (paymentInput) {
      paymentInput.value = "google_pay"
      paymentInput.id = 'google_pay'
    }

    const submitBtn = document.querySelector('#espago_form [data-payment-target="formBtn"]')
    if (submitBtn) submitBtn.click()
  }

  baseRequest() {
    return { apiVersion: 2, apiVersionMinor: 0 }
  }

  isReadyToPayRequest() {
    return {
      ...this.baseRequest(),
      allowedPaymentMethods: [this.baseCardPaymentMethod()],
    }
  }

  paymentDataRequest() {
    return {
      ...this.baseRequest(),
      allowedPaymentMethods: [this.cardPaymentMethod()],
      transactionInfo: this.transactionInfo(),
      merchantInfo: {
        merchantName: "Example Merchant",
      },
    }
  }

  baseCardPaymentMethod() {
    return {
      type: "CARD",
      parameters: {
        allowedAuthMethods: ["PAN_ONLY", "CRYPTOGRAM_3DS"],
        allowedCardNetworks: ["VISA", "MASTERCARD"],
      },
    }
  }

  cardPaymentMethod() {
    return {
      ...this.baseCardPaymentMethod(),
      tokenizationSpecification: {
        type: "PAYMENT_GATEWAY",
        parameters: {
          gateway: "example",
          gatewayMerchantId: "exampleGatewayMerchantId",
        },
      },
    }
  }

  transactionInfo() {
    return {
      countryCode: "PL",
      currencyCode: "PLN",
      totalPriceStatus: "FINAL",
      totalPrice: this.amountValue
    }
  }
}
