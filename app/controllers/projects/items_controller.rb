class Projects::ItemsController < ApplicationController
  before_action :project
  layout "project"

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Projects", :projects_path

  protected

  def add_project_breadcrumb
    add_breadcrumb @project.name, project_path(params[:project_id])
  end

  def project
    @project = Project.find(params[:project_id])
    return render_404 unless can?(current_user, :read_project, @project) 

    @project.touch_opening(current_user.id)
    gon.project_id    = @project.id
    gon.project_state = @project.state
  end

end