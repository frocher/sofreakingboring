class Projects::TimesheetsController < Projects::ItemsController

  # Start editing timesheet
  def edit
    add_project_breadcrumb
    add_breadcrumb "My Timesheet", :edit_project_timesheet_path

    today = Date.today
    @period_start    = today.beginning_of_week
    @period_end      = @period_start + 4
    gon.user_id      = current_user.id
    gon.period_start = @period_start.strftime("%Y%m%d")
    gon.period_end   = @period_end.strftime("%Y%m%d")
    gon.can_update_members_task_work = can?(current_user, :update_members_task_work, @project)
  end

end
