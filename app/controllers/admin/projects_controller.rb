class Admin::ProjectsController < Admin::AdminController
  add_breadcrumb "Home", :root_path
  add_breadcrumb "Projects", :admin_projects_path

  def index
    @projects = Project.order(:name).page(params[:page])
  end

end
