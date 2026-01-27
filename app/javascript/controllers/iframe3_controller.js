import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    publicKey: String,
    espagoPaymentToken: String,
    espagoPaymentId: String
  }

  connect() {
    this.loadEspagoMain()
      .then(() => this.loadIframe3())
      .then(() => this.showIframe3())
      .catch(error => console.error("Error:", error))
  }

  loadEspagoMain() {
    return this.loadScript("https://js.espago.com/espago-1.3.js")
  }


  loadIframe3() {
    return this.loadScript('https://js.espago.com/espagoFrame.js')
  }

  loadScript(src, attrs = {}) {
    return new Promise((resolve, reject) => {
      const existing = document.querySelector(`script[src="${src}"]`)
      if (existing) return resolve()

      const script = document.createElement("script")
      script.src = src

      Object.keys(attrs).forEach(key => {
        script.setAttribute(key, attrs[key])
      })

      script.onload = () => resolve()
      script.onerror = () => reject()

      document.body.appendChild(script)
    })
  }

  async showIframe3() {
    const espagoFrame = new EspagoFrame({
        key: this.publicKeyValue,
        env: "sandbox",
        payment: this.espagoPaymentIdValue,
        token: this.espagoPaymentTokenValue
    })
    await espagoFrame.init()

    const onPaymentResult = () =>
      this.submitIframe3Result({ espago_payment_id: this.espagoPaymentIdValue })

    const onError = () =>
      this.submitIframe3Result({ espago_payment_id: this.espagoPaymentIdValue })

    const onClose = () =>
      this.submitIframe3Result({ espago_payment_id: this.espagoPaymentIdValue })

    espagoFrame.open({
      onPaymentResult: onPaymentResult,
      onError: onError,
      onClose: onClose
    })
  }

  submitIframe3Result(payload = {}) {
    const form = document.createElement("form")
    form.method = "POST"
    form.action = "/payments/iframe3_callback"

    Object.entries(payload).forEach(([name, value]) => {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = name
      input.value = value
      form.appendChild(input)
    })
    
    const csrfToken =
      document.querySelector('meta[name="csrf-token"]')?.content

    if (csrfToken) {
      const csrf = document.createElement("input")
      csrf.type = "hidden"
      csrf.name = "authenticity_token"
      csrf.value = csrfToken
      form.appendChild(csrf)
    }
    document.body.appendChild(form)
    form.submit()
  }
}
