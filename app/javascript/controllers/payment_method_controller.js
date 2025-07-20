import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "payBtn",
    "secureBtn",
    "processBtn",
    "form",
    "radio",
    "saveCardCheckbox" 
  ]

  connect() {
    this.payBtnTarget.addEventListener("click", () => this.handlePayClick())
    this.radioTargets.forEach(radio => {
      radio.addEventListener("change", () => this.toggleSaveCardCheckbox())
    })
    this.toggleSaveCardCheckbox()
  }

  toggleSaveCardCheckbox() {
    const selected = this.radioTargets.find(radio => radio.checked)
    if (!selected) return

    if (selected.value.startsWith("cli")) {
      this.saveCardCheckboxTarget.classList.add("d-none")
      const checkbox = this.saveCardCheckboxTarget.querySelector("input[type='checkbox']")
      if (checkbox) checkbox.checked = false
    } else {
      this.saveCardCheckboxTarget.classList.remove("d-none")
    }
  }

  handlePayClick() {
    if (!this.formTarget.reportValidity()) return

    const selected = this.radioTargets.find(radio => radio.checked)
    if (!selected) return

    if (selected.value === "new_one_time") {
      setTimeout(() => {
        if (typeof showEspagoFrame === "function") {
          showEspagoFrame()
        } else {
          alert("Payment system not ready. Please wait and try again.")
        }
      }, 100)
    } else if (selected.value === "new_secure_web_page") {
      this.processBtnTarget.click()
    } else if (selected.value.startsWith("cli")) {
      this.formTarget.submit()
    } else {
      alert("Unsupported payment method.")
    }
  }
}
