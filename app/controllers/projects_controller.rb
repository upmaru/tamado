class ProjectsController < ApplicationController
  def index
    @projects = current_user.projects.includes(:lists).order(:name)
  end

  def show
    @project = current_user.projects.find(params[:id])
    @lists = @project.lists.includes(items: %i[attachments_attachments tags]).order(:name)
  end

  def new
    @project = current_user.projects.build
  end

  def create
    project = current_user.projects.create!(project_params)
    redirect_to projects_path
  end

  private

  def project_params
    params.expect(project: :name)
  end
end
