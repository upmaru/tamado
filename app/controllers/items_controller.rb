class ItemsController < ApplicationController
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
    @item = Item
             .joins(list: :project)
             .where(id: params[:id], projects: { user_id: current_user.id })
             .includes(list: :project)
             .first
    return head :not_found unless @item

    @events = @item.events.order(:created_at)
    @transitions = @item.state_transitions.where.not(from: [ nil, "" ]).order(:created_at)
  end

  def update
    project = current_user.projects.find(params[:project_id])
    item = project.items.find(params[:id])
    item.actor = current_user
    item.complete! if item.pending?

    redirect_to project
  end

  private

  def item_params
    params.expect(item: :description)
  end
end
