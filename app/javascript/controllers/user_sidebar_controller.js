import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = [
      "rubitsSection",
      "likesSection",
      "commentsSection",
      "ordersSection",
    ]


    toggleRubitsSection() {
      this.toggleContent("rubits")
    }

    toggleLikesSection() {
      this.toggleContent("likes")
    }

    toggleCommentsSection() {
      this.toggleContent("comments")
    }

    toggleOrdersSection() {
      this.toggleContent("orders")
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