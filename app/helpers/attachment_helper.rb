module AttachmentHelper
  def attachment_is_image?(attachment)
    attachment.blob.content_type.to_s.start_with?("image/")
  end

  def attachment_icon(attachment)
    icon_name, color =
      case attachment_file_kind(attachment)
      when :pdf then [ "file", "text-error" ]
      when :text then [ "file-text", "text-primary" ]
      else [ "file", "text-base-content/50" ]
      end

    icon icon_name, class: [ "size-10", color ].join(" ")
  end

  private

  def attachment_file_kind(attachment)
    ext = attachment.filename.extension.to_s.downcase
    content_type = attachment.blob.content_type.to_s

    if content_type == "application/pdf" || ext == "pdf"
      :pdf
    elsif content_type.start_with?("text/") || %w[ txt csv md log json js yaml yml toml xml ].include?(ext)
      :text
    else
      :other
    end
  end
end
