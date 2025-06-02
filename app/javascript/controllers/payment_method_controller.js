import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["payBtn", "secureBtn", "processBtn", "form", "radio"]

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

handlePayClick() {
  if (!this.formTarget.reportValidity()) return;

  setTimeout(() => {
    if (typeof showEspagoFrame === "function") {
      showEspagoFrame();
    } else {
      alert("Payment system not ready. Please wait and try again.");
    }
  }, 100)
}

  handleSecureClick() {
    if (!this.formTarget.reportValidity()) return
    this.processBtnTarget.click()
  }
}
