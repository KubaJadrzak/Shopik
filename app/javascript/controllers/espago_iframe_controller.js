import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "processBtn"]

  connect() {
    window.espagoCallback = (token) => {
      let tokenField = this.formTarget.querySelector('#card_token')
      if (!tokenField) {
        tokenField = document.createElement("input")
        tokenField.type = "hidden"
        tokenField.name = "card_token"
        tokenField.id = "card_token"
        this.formTarget.appendChild(tokenField)
      }
      tokenField.value = token
      this.processBtnTarget.click()
    }
  }
}
