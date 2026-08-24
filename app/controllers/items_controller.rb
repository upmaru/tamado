class ItemsController < ApplicationController
  def index
    @tag_ids = Array(params[:tag_ids]).reject(&:blank?)
    @tags = Tag.where(id: @tag_ids)
    @items = current_user_items
    @items = @items.where(id: Item::Tagging.where(tag_id: @tag_ids).select(:item_id)) if @tag_ids.any?
    @items = @items.order(updated_at: :desc)
  end

  def create
    @project = current_user.projects.find(params[:project_id])
    @list = @project.lists.find(params[:list_id])
    @item = @list.items.new(item_params)
    @item.creator = current_user
    @item.save!

    respond_to do |format|
      format.html { redirect_to @project }
      format.turbo_stream
    end
  end

  def show
    @item = find_item(params[:id])
    return head :not_found unless @item

    @item.actor = current_user
    @item.seen! if @item.pending?

    @events = @item.events.order(:created_at)
    @transitions = @item.state_transitions.where.not(from: [ nil, "" ]).order(:created_at)
  end

  def edit
    @item = find_item(params[:id])
    head :not_found unless @item
  end

  def update
    if params[:project_id].present?
      complete_item
    else
      edit_item
    end
  end

  private

  def current_user_items
    Item.joins(list: :project)
        .where(projects: { user_id: current_user.id })
        .includes(:tags, :events, list: :project)
  end

  def find_item(item_id)
    Item.joins(list: :project)
        .where(id: item_id, projects: { user_id: current_user.id })
        .includes(list: :project, taggings: :tag)
        .first
  end

  def complete_item
    project = current_user.projects.find(params[:project_id])
    item = project.items.find(params[:id])
    item.actor = current_user
    item.complete! if item.can_complete?

    redirect_to project
  end

  def edit_item
    @item = find_item(params[:id])
    return head :not_found unless @item

    if @item.update(item_params)
      redirect_to item_path(@item)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def item_params
    params.expect(item: :description)
  end
end
