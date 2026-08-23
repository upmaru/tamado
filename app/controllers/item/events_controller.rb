class Item::EventsController < ApplicationController
  def new
    @item = find_item(params[:item_id])
    return head :not_found unless @item

    @event = @item.events.new
  end

  def create
    @item = find_item(params[:item_id])
    return head :not_found unless @item

    @event = @item.events.new(kind: params[:event][:kind])
    at = params[:event][:at].presence
    @event.data = { "at" => Time.zone.parse(at).iso8601 } if at

    if @event.save
      redirect_to item_path(@item)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def find_item(item_id)
    Item.joins(list: :project)
        .where(id: item_id, projects: { user_id: current_user.id })
        .includes(list: :project)
        .first
  end
end
