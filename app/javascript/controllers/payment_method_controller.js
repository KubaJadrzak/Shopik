import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "payBtn",
    "secureBtn",
    "processBtn",
    "form",
    "radio",
    "radioGroup",
    "saveCardCheckbox",
    "savedCard"
  ]

  connect() {
    this.updateButton()
    this.radioTargets.forEach(radio =>
      radio.addEventListener("change", () => this.updateButton())
    )

    this.payBtnTarget.addEventListener("click", () => this.handlePayClick())
    this.secureBtnTarget.addEventListener("click", () => this.handleSecureClick())
  }

  updateButton() {
    const selected = this.radioTargets.find(r => r.checked)
    if (selected && selected.value === "secure_web_page") {
      this.payBtnTarget.classList.add("d-none")
      this.secureBtnTarget.classList.remove("d-none")
    } else {
      this.secureBtnTarget.classList.add("d-none")
      this.payBtnTarget.classList.remove("d-none")
    }
  }

  updateSavedCard() {
    const selected = this.savedCardTargets.find(r => r.checked)

    if (selected && selected.value !== "") {
      // Hide options for new card
      this.radioGroupTarget.classList.add("d-none")
      this.saveCardCheckboxTarget.classList.add("d-none")

      // Show submit for stored card
      this.payBtnTarget.classList.add("d-none")
      this.secureBtnTarget.classList.remove("d-none")
    } else {
      this.radioGroupTarget.classList.remove("d-none")
      this.saveCardCheckboxTarget.classList.remove("d-none")
      this.updateButton()
    }
  }

  handlePayClick() {
    if (!this.formTarget.reportValidity()) return

    setTimeout(() => {
      if (typeof showEspagoFrame === "function") {
        showEspagoFrame()
      } else {
        alert("Payment system not ready. Please wait and try again.")
      }
    }, 100)
  }

  handleSecureClick() {
    if (!this.formTarget.reportValidity()) return
    this.processBtnTarget.click()
  }
}