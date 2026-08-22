class ProjectsController < ApplicationController
  def index
    @projects = Project.order(:name)
  end

  def show
    @project = Project.find(params[:id])
  end
end
