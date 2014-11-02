class Projects::TasksController < Projects::ItemsController

  def index
    add_project_breadcrumb
    add_breadcrumb "Tasks", :project_tasks_path

    gon.user_id                  = current_user.id
    gon.can_update_tasks         = can?(current_user, :update_project_task,  @project)
    gon.can_take_unassigned_task = can?(current_user, :take_unassigned_task, @project)
  end

end
