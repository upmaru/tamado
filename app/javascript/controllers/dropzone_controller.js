import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "fileInput", "dropArea" ]

  connect() {
    this.dropAreaTarget.addEventListener("dragover", this.onDragOver)
    this.dropAreaTarget.addEventListener("dragleave", this.onDragLeave)
    this.dropAreaTarget.addEventListener("drop", this.onDrop)
    this.dropAreaTarget.addEventListener("click", this.onBrowse)
    this.fileInputTarget.addEventListener("change", this.onSubmit)
  }

  disconnect() {
    this.dropAreaTarget.removeEventListener("dragover", this.onDragOver)
    this.dropAreaTarget.removeEventListener("dragleave", this.onDragLeave)
    this.dropAreaTarget.removeEventListener("drop", this.onDrop)
    this.dropAreaTarget.removeEventListener("click", this.onBrowse)
    this.fileInputTarget.removeEventListener("change", this.onSubmit)
  }

  onDragOver = (event) => {
    event.preventDefault()
    this.dropAreaTarget.classList.add("border-primary", "bg-primary/10")
  }

  onDragLeave = () => {
    this.dropAreaTarget.classList.remove("border-primary", "bg-primary/10")
  }

  onDrop = (event) => {
    event.preventDefault()
    this.dropAreaTarget.classList.remove("border-primary", "bg-primary/10")

    const files = event.dataTransfer?.files
    if (files.length === 0) {
      return
    }

    const dataTransfer = new DataTransfer()
    ;[ ...files ].forEach((file) => dataTransfer.items.add(file))
    this.fileInputTarget.files = dataTransfer.files
    this.submitForm()
  }

  onBrowse = () => {
    this.fileInputTarget.click()
  }

  onSubmit = () => {
    this.submitForm()
  }

  submitForm() {
    if (this.fileInputTarget.files.length > 0) {
      this.fileInputTarget.form.requestSubmit()
    }
  }
}
