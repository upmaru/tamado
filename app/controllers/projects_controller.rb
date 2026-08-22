class ProjectsController < ApplicationController
  def index
    @projects = Project.includes(:lists).order(:name)
  end

  def show
    @project = Project.find(params[:id])
    @lists = @project.lists.includes(:items).order(:name)
  end
end
