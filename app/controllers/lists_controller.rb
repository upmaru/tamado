class ListsController < ApplicationController
  def new
    @project = current_user.projects.find(params[:project_id])
    @list = @project.lists.build
  end

  def create
    @project = current_user.projects.find(params[:project_id])
    @project.lists.create!(list_params)

    redirect_to @project
  end

  private

  def list_params
    params.expect(list: :name)
  end
end
