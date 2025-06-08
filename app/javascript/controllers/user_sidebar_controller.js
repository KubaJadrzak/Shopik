import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "rubitsSection",
    "likesSection",
    "commentsSection",
    "ordersSection",
    'subscriptionsSection'
  ]

connect() {
  this.boundShowSection = this.showSectionFromHash.bind(this)
  this.boundHandleMorph = this.handleMorph.bind(this)

  this.showSectionFromHash()
  window.addEventListener("hashchange", this.boundShowSection)
  document.addEventListener("turbo:morph", this.boundHandleMorph)
}

disconnect() {
  window.removeEventListener("hashchange", this.boundShowSection)
  document.removeEventListener("turbo:morph", this.boundHandleMorph)
}

  handleMorph() {
    this.showSectionFromHash()
  }

  showSectionFromHash() {
    const hash = window.location.hash.replace("#", "")
    if (["rubits", "likes", "comments", "orders", "subscriptions"].includes(hash)) {
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

  toggleSubscriptionsSection() {
    this.setHash("subscriptions")
  }

  setHash(section) {
    history.pushState(null, "", `#${section}`)
    this.toggleContent(section)
  }

  toggleContent(contentType) {
    this.hideAllSections()
    const section = this[`${contentType}SectionTarget`]
    if (section) {
      section.classList.remove("d-none")
    }
  }

  hideAllSections() {
    if (this.hasRubitsSectionTarget) this.rubitsSectionTarget.classList.add("d-none")
    if (this.hasLikesSectionTarget) this.likesSectionTarget.classList.add("d-none")
    if (this.hasCommentsSectionTarget) this.commentsSectionTarget.classList.add("d-none")
    if (this.hasOrdersSectionTarget) this.ordersSectionTarget.classList.add("d-none")
    if (this.hasSubscriptionsSectionTarget) this.subscriptionsSectionTarget.classList.add("d-none")
  }
}