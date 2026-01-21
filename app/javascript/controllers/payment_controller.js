import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    publicKey: String
  }

  static targets = ["form", "formBtn", "paymentMethod", "saveCard"]

  connect() {
    this.loadEspagoMain()
      .then(() => this.loadIframe())
      .then(() => this.loadIframe3())
      .then(() => this.initializePayment())
      .catch(error => console.error("Error:", error))
  }

  loadEspagoMain() {
    return this.loadScript("https://js.espago.com/espago-1.3.js")
  }

  loadIframe() {
    return this.loadScript("https://js.espago.com/iframe.js", {
      async: true,
      "data-id": "EspagoFrameScript",
      "data-key": this.publicKeyValue,
      "data-live": 'false',
      "data-button": "Pay"
    })
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

  initializePayment() {
    this.updatePaymentMethod()
    this.updateSaveCard()
  }

  updatePaymentMethod() {
    const checked = this.paymentMethodTargets.find(r => r.checked)
    this.selectedPaymentMethod = checked ? checked.value : 'secure_web_page'
    if (checked && checked.value.startsWith("cli")) {
      this.saveCardTargets.forEach(c => {
        c.checked = false
        c.disabled = true
      })
    } else {
      this.saveCardTargets.forEach(c => {
        c.disabled = false
      })
    }
  }

  updateSaveCard() {
    this.saveCard = this.saveCardTargets.some(c => c.checked)
  }

  processPayment() {
    this.updateForm()
    console.log(this.selectedPaymentMethod)
    switch(this.selectedPaymentMethod) {
      case 'iframe':
        return showEspagoFrame()
      case 'iframe3':
        return this.initializeIframe3()
      default:
        this.formBtnTarget.click()
    }
  }

  updateForm() {
    if (this.saveCard == true) {
      const saveCardInput = document.createElement("input")
      saveCardInput.type = "hidden"
      saveCardInput.name = "cof"
      saveCardInput.value = "storing"
      this.formTarget.appendChild(saveCardInput)
    }
  }

  async initializeIframe3() {
    const formData = new FormData(this.formTarget)

    const response = await fetch(this.formTarget.action, {
      method: this.formTarget.method || "POST",
      body: formData,
      headers: {
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      }
    })

    const data = await response.json()
    await this.showIframe3(data)
  }

  async showIframe3(data) {
    const espagoFrame = new EspagoFrame({
        key: this.publicKeyValue,
        env: "sandbox",
        payment: data.payment,
        token: data.token
    })
    await espagoFrame.init()

    const onPaymentResult = (result) => {
      const form = document.createElement("form")
      form.method = "POST"
      form.action = "/payments/iframe3_callback"

      const response = document.createElement("input")
      response.type = "hidden"
      response.name = "finished"
      response.value = result.payment_id
      form.appendChild(response)

      const csrfInput = document.createElement("input")
      csrfInput.type = "hidden"
      csrfInput.name = "authenticity_token"
      csrfInput.value = document.querySelector('meta[name="csrf-token"]').content
      form.appendChild(csrfInput)

      document.body.appendChild(form)
      form.submit()
    }

    const onError = () => {
      const form = document.createElement("form")
      form.method = "POST"
      form.action = "/payments/iframe3_callback"

      const response = document.createElement("input")
      response.type = "hidden"
      response.name = "unfinished"
      form.appendChild(response)

      const csrfInput = document.createElement("input")
      csrfInput.type = "hidden"
      csrfInput.name = "authenticity_token"
      csrfInput.value = document.querySelector('meta[name="csrf-token"]').content
      form.appendChild(csrfInput)

      document.body.appendChild(form)
      form.submit()
    };

    const onClose = () => {
      const form = document.createElement("form")
      form.method = "POST"
      form.action = "/payments/iframe3_callback"

      const response = document.createElement("input")
      response.type = "hidden"
      response.name = "unfinished"
      form.appendChild(response)

      const csrfInput = document.createElement("input")
      csrfInput.type = "hidden"
      csrfInput.name = "authenticity_token"
      csrfInput.value = document.querySelector('meta[name="csrf-token"]').content
      form.appendChild(csrfInput)

      document.body.appendChild(form)
      form.submit()
    };

    espagoFrame.open({
      onPaymentResult: onPaymentResult,
      onError: onError,
      onClose: onClose
    })
  }
}
