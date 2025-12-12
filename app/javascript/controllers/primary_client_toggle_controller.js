import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  async toggle() {
    const token = document.querySelector("meta[name=csrf-token]").content
    await fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "Accept": "text/vnd.turbo-stream.html",
        "X-CSRF-Token": token
      },
    })
  }
}