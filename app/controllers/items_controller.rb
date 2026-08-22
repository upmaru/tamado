class ItemsController < ApplicationController
  def create
    @project = Project.find(params[:project_id])
    @list = @project.lists.find(params[:list_id])
    @item = @list.items.create!(item_params)

    respond_to do |format|
      format.html { redirect_to @project }
      format.turbo_stream
    end
  end

  def show
    @item = Item.includes(list: :project).find(params[:id])
    @transitions = @item.item_state_transitions.where.not(from: [ nil, "" ]).order(:created_at)
  end

  def update
    project = Project.find(params[:project_id])
    item = project.items.find(params[:id])
    item.complete! if item.pending?

    redirect_to project
  end

  private

  def item_params
    params.expect(item: :description)
  end
end
