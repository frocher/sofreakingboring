class ProjectsController < ApplicationController
  before_action :project, only: [:show, :edit, :update, :destroy]

  layout "project", only: [:show, :show_export]

  add_breadcrumb "Home", :root_path
  add_breadcrumb "Projects", :projects_path

  def index
    @projects = current_user.projects.order(:name).page(params[:page])
  end

  def show
    add_breadcrumb @project.name, :project_path
  end

  def new
    add_breadcrumb "New", :new_project_path
    session[:return_to] = request.referer
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    if @project.save
      member = ProjectMember.new
      member.project = @project
      member.user = current_user
      member.role = :admin
      member.save!

      flash[:notice] = "Project was successfully created"
      redirect_to project_path(@project)
    else
      render "new"
    end
  end

  def edit
    return render_404 unless can?(current_user, :update_project, @project)
    add_breadcrumb "Edit #{@project.name}", :edit_project_path
    session[:return_to] = request.referer
  end

  def update
    return render_404 unless can?(current_user, :update_project, @project)
    if @project.update_attributes(project_params)
      flash[:notice] = "Project was successfully updated"
      redirect_to session.delete(:return_to)
    else
      render "edit"
    end
  end

  def destroy
    return render_404 unless can?(current_user, :delete_project, @project)
    if @project.destroy
      flash[:notice] = "Project was successfully removed"
    end
    redirect_to projects_path
  end

  def remove_attachment
    @project = Project.find(params[:project_id])
    return render_404 unless can?(current_user, :update_project, @project)
    @project.attachment = nil
    @project.save
    flash[:notice] = "Picture was successfully removed"
    redirect_to :back
  end

  def show_export
    @project = Project.find(params[:project_id])
    return render_404 unless can?(current_user, :export_project, @project)
    add_breadcrumb @project.name, :project_show_export_path
  end

  def export
    @project = Project.find(params[:project_id])
    return render_404 unless can?(current_user, :export_project, @project)
    respond_to do |format|
      format.xlsx
    end
  end

  private

  def project
    @project = Project.find(params[:id])
    return render_404 unless can?(current_user, :read_project, @project)
    
    @project.touch_opening(current_user.id)
    gon.project_id = @project.id
  end 

  def project_params
    params.require(:project).permit(:name, :code, :description, :state, :attachment)
  end
end
