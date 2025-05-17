import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  remove() {
    this.element.remove();
  }
}

document.addEventListener("turbo:visit", () => {
  const flash = document.getElementById("flash");
  if (flash) {
    flash.innerHTML = "";
  }
});