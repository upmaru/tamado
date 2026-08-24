class Item::AttachmentsController < ApplicationController
  def create
    @item = find_item(params[:item_id])
    return head :not_found unless @item

    uploads = Array(params.dig(:item, :attachments)).compact_blank
    @item.attachments.attach(uploads) if uploads.any?

    redirect_to item_path(@item), notice: uploads.any? ? "Files added." : "No files added."
  end

  def destroy
    @item = find_item(params[:item_id])
    return head :not_found unless @item

    @item.attachments.find(params[:id]).purge
    redirect_to item_path(@item), notice: "File removed."
  end

  private

  def find_item(item_id)
    Item.joins(list: :project)
        .where(id: item_id, projects: { user_id: current_user.id })
        .includes(list: :project)
        .first
  end
end
