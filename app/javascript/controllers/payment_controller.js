import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    publicKey: String
  }

  static targets = ["form", "formBtn", "paymentMethod", "saveCard"]

  connect() {
    this.loadEspagoMain()
      .then(() => this.loadIframe())
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
        return this.formBtnTarget.click()
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
}
