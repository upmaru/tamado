import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static targets = [ "handle" ]

  connect() {
    this.sortable = new Sortable(this.element, {
      handle: "[data-reorder-target='handle']",
      animation: 150,
      ghostClass: "opacity-40",
      onEnd: this.onEnd
    })
  }

  disconnect() {
    this.sortable.destroy()
  }

  onEnd = (event) => {
    const ids = [ ...this.element.querySelectorAll("li") ].map((item) => item.dataset.id)

    fetch(this.data.get("url"), {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
      },
      body: JSON.stringify({ ids: ids })
    }).catch(() => this.sortable.moveTo(event.newIndex, event.oldIndex))
  }
}
