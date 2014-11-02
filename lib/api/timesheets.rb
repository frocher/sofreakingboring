module API
  # Timesheets API
  class Timesheets < Grape::API
    before { authenticate! }

    helpers do       
      def compute_end(start)
        endDate = DateTime.strptime(start, "%Y%m%d")
        endDate += 6.days
        endDate.strftime("%Y%m%d")
      end

      def find_member(project_id, user_id)
        ProjectMember.where("user_id=? and project_id=?", user_id, project_id).first
      end
    end

    resource :projects do

      desc "Returns all tasks for a given period."
      get ":id/timesheets/:start/tasks" do
        authorize! :read_project, user_project        
        period_start = params[:start]
        period_end = compute_end(period_start)
        user_id = params[:user_id] || current_user.id
        member = find_member(params[:id], user_id)
        tasks  = member.assigned_tasks
        timesheet_tasks = []
        tasks.each do |task|
          timesheet_task = TimesheetTask.new(task, period_start, period_end)
          timesheet_tasks << timesheet_task
        end

        present timesheet_tasks, with: Entities::TimesheetTask
      end

    end

  end
end
