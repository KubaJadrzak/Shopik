import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "rubitsSection",
    "likesSection",
    "commentsSection",
    "ordersSection"
  ]

  connect() {
    this.showSectionFromHash()
    window.addEventListener("hashchange", this.showSectionFromHash.bind(this))
  }

  disconnect() {
    window.removeEventListener("hashchange", this.showSectionFromHash.bind(this))
  }

  showSectionFromHash() {
    const hash = window.location.hash.replace("#", "")
    if (["rubits", "likes", "comments", "orders"].includes(hash)) {
      this.toggleContent(hash)
    } else {
      this.toggleContent("rubits")
    }
  }

  toggleRubitsSection() {
    this.setHash("rubits")
  }

  toggleLikesSection() {
    this.setHash("likes")
  }

  toggleCommentsSection() {
    this.setHash("comments")
  }

  toggleOrdersSection() {
    this.setHash("orders")
  }

  setHash(section) {
    history.pushState(null, "", `#${section}`)
    this.toggleContent(section)
  }

  toggleContent(contentType) {
    this.hideAllSections()
    const section = this[`${contentType}SectionTarget`]
    if (section) section.classList.remove("d-none")
  }

  hideAllSections() {
    this.rubitsSectionTarget.classList.add("d-none")
    this.likesSectionTarget.classList.add("d-none")
    this.commentsSectionTarget.classList.add("d-none")
    this.ordersSectionTarget.classList.add("d-none")
  }
}
