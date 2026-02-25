import { Controller } from "@hotwired/stimulus"
import * as bootstrap from "bootstrap"

export default class extends Controller {

  async connect() {
  if (this.shouldUseRealApplePay()) {
    await this.loadApplePaySdk()
  }
    this.addApplePayButton()
  }

  loadApplePaySdk() {
    return new Promise((resolve, reject) => {
      if (window.ApplePaySession) {
        resolve()
        return
      }

      const script = document.createElement("script")
      script.src = "https://applepay.cdn-apple.com/jsapi/1.latest/apple-pay-sdk.js"
      script.crossOrigin = "anonymous"
      script.onload = resolve
      script.onerror = reject
      document.head.appendChild(script)
    })
  }

  addApplePayButton() {
    const button = this.isApplePayAvailable() ? this.createApplePayButton() : this.createSimulatedApplePayButton()

    button.addEventListener("click", (e) => {
      e.preventDefault()
      this.showApplePayModal()
      this.addApplePayButtonModal()
    })

    this.element.appendChild(button)
  }

  addApplePayButtonModal() {
    const container = document.querySelector("#applePayModal .apple-pay-modal-button")
    if (!container) return

    if (container.querySelector(".simulated-apple-pay, apple-pay-button")) return

    const button = this.isApplePayAvailable() ? this.createApplePayButton() : this.createSimulatedApplePayButton()
    button.addEventListener("click", (e) => {
      e.preventDefault()
      document
        .querySelectorAll('input[name="payment_method"]')
        .forEach(r => r.checked = false)

      const appleRadio = document.querySelector('#apple_pay')
      appleRadio.checked = true

      const submitBtn = document.querySelector('#espago_form [data-payment-target="formBtn"]')
      if (submitBtn) submitBtn.click()
    })
    container.appendChild(button)
  }

  createApplePayButton() {
    const button = document.createElement("apple-pay-button")
    button.setAttribute("buttonstyle", "black")
    button.setAttribute("type", "buy")
    button.setAttribute("locale", "en-US")
    button.style.setProperty("--apple-pay-button-width", "100%")
    button.style.setProperty("--apple-pay-button-height", "40px")
    button.style.setProperty("--apple-pay-button-padding", "5px 0px")
    button.style.setProperty("--apple-pay-button-box-sizing", "border-box")
    return button
  }

  createSimulatedApplePayButton() {
    const button = document.createElement("button")
    button.type = "button"
    button.className = "simulated-apple-pay"
    button.innerHTML = "Apple Pay (Simulated)"

    button.style.width = "100%"
    button.style.height = "40px"
    button.style.background = "black"
    button.style.color = "white"
    button.style.border = "none"
    button.style.borderRadius = "3px"
    button.style.fontSize = "16px"
    button.style.cursor = "pointer"

    return button
  }

  showApplePayModal() {
    const modalEl = document.getElementById("applePayModal")
    const modal = new bootstrap.Modal(modalEl)
    modal.show()
  }

  isApplePayAvailable() {
    return (window.ApplePaySession && ApplePaySession.canMakePayments())
  }

  shouldUseRealApplePay() {
    return window.location.protocol === "https:"
  }
}

