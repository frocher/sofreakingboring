module API
  # WorkLogs API
  class WorkLogs < Grape::API
    before { authenticate! }

    resource :projects do

      desc "Returns all work logs for a given task."
      get ":id/tasks/:task_id/work_logs" do
        authorize! :read_project, user_project
        @task = user_project.tasks.find(params[:task_id])
        present paginate(@task.work_logs), with: Entities::WorkLog
      end

      desc "Returns a work log for a given day."
      get ":id/tasks/:task_id/work_logs/:day" do
        authorize! :read_project, user_project
        @task = user_project.tasks.find(params[:task_id])
        present @task.work_logs.find_by(day: params[:day]), with: Entities::WorkLog
      end

      desc "create or update a work log for a given day."
      put ":id/tasks/:task_id/work_logs/:day" do
        authorize! :update_task_work, user_project
        @task = user_project.tasks.find(params[:task_id])

        if @task.assignee.id == current_user.id || can?(current_user, :update_members_task_work, user_project)
          @log = @task.work_logs.find_by(day: params[:day])
          unless @log
            @log = WorkLog.new 
            @log.task_id = @task.id
            @log.day = params[:day]
          end
          @log.worked = params[:worked]

          if @log.save
            present @log, with: Entities::WorkLog
          else
            not_found!
          end
        else
          forbidden!
        end
      end
   
    end
  end
end
