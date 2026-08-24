class Item::TaggingsController < ApplicationController
  def destroy
    @item = find_item(params[:item_id])
    return head :not_found unless @item

    @item.taggings.find(params[:id]).destroy
    redirect_to item_path(@item), notice: "Tag removed."
  end

  private

  def find_item(item_id)
    Item.joins(list: :project)
        .where(id: item_id, projects: { user_id: current_user.id })
        .includes(list: :project)
        .first
  end
end
