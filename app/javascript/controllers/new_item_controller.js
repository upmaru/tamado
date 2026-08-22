import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "form", "input"]

  show() {
    this.buttonTarget.hidden = true
    this.formTarget.hidden = false
    this.inputTarget.focus()
  }

  hide() {
    this.formTarget.hidden = true
    this.buttonTarget.hidden = false
  }

  reset(event) {
    if (event.detail.success) {
      this.formTarget.reset()
      this.inputTarget.focus()
    }
  }
}
