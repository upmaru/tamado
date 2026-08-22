class ListsController < ApplicationController
  def show
    @project = Project.find(params[:project_id])
    @list = @project.lists.find(params[:id])
    @items = @list.items.order(:created_at)
  end
end
