import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  connect() {
    this.originalLabel = this.buttonTarget.innerHTML
    this.boundEnd = this.submitEnd.bind(this)
    this.element.addEventListener("turbo:submit-end", this.boundEnd)
  }

  disconnect() {
    this.element.removeEventListener("turbo:submit-end", this.boundEnd)
  }

  submitStart() {
    this.buttonTarget.disabled = true
    this.buttonTarget.setAttribute("aria-busy", "true")
    this.buttonTarget.innerHTML = '<span class="spinner" aria-hidden="true"></span> Searching\u2026'
  }

  submitEnd() {
    if (!this.buttonTarget.disabled) return
    this.buttonTarget.disabled = false
    this.buttonTarget.removeAttribute("aria-busy")
    this.buttonTarget.innerHTML = this.originalLabel
  }
}
