module API
  # Tasks API
  class Tasks < Grape::API
    before { authenticate! }

    resource :projects do

      # Get a list of project tasks
      #
      # Parameters:
      #   id (required) - The ID of a project
      # Example Request:
      #   GET /projects/:id/tasks
      get ":id/tasks" do
        authorize! :read_project, user_project
        present paginate(user_project.tasks), with: Entities::Task
      end

      # Get a single project task
      #
      # Parameters:
      #   id (required) - The ID of a project
      #   task_id (required) - The ID of a project task
      # Example Request:
      #   GET /projects/:id/tasks/:task_id
      get ":id/tasks/:task_id" do
        authorize! :read_project, user_project        
        @task = user_project.tasks.find(params[:task_id])
        present @task, with: Entities::Task
      end

      # Create a new project task
      #
      # Parameters:
      #   id (required) - The ID of a project
      #   name (required) - The name of a task
      #   description (optional) - The description of a task
      #   original_estimate (optional) - The original estimate of the task. Defaults to 0.
      #   assignee_id (optional) - The ID of a user to assign task
      # Example Request:
      #   POST /projects/:id/tasks
      post ":id/tasks" do
        set_current_user_for_thread do
          required_attributes! [:name]
          authorize! :create_project_task, user_project
          attrs = attributes_for_keys [:name, :description, :original_estimate, :assignee_id, :tag_list]
          @task = user_project.tasks.new attrs
          @task.original_estimate = 0 if @task.original_estimate.nil?
          @task.remaining_estimate = 0 if @task.remaining_estimate.nil?
          if @task.save
            present @task, with: Entities::Task
          else
            not_found!
          end
        end
      end

      # Update an existing task
      #
      # Parameters:
      #   id (required) - The ID of a project
      #   task_id (required) - The ID of a project task
      #   name (optional) - The name of a task
      #   description (optional) - The description of a task
      #   assignee_id (optional) - The ID of a user to assign task
      #   original_estimate (optional) - The original estimate of a task
      #   remaining_estimate (optional) - The remaining estimate of a task
      # Example Request:
      #   PUT /projects/:id/tasks/:task_id
      put ":id/tasks/:task_id" do
        set_current_user_for_thread do

          attrs = []
          if can?(current_user, :update_project_task, user_project) || can?(current_user, :take_unassigned_task, user_project)
            attrs = []
            if can?(current_user, :update_project_task, user_project)
              attrs = attributes_for_keys [:name, :description, :assignee_id, :original_estimate, :remaining_estimate, :tag_list]
            else
              attrs = attributes_for_keys [:assignee_id]
            end
            @task = user_project.tasks.find(params[:task_id])
            if @task.update_attributes attrs
              present @task, with: Entities::Task
            else
              not_found!
            end
          else
            forbidden!
          end
        end
      end

      put ":id/tasks/:task_id/remaining" do
        set_current_user_for_thread do
          authorize! :update_task_work, user_project
          @task = user_project.tasks.find(params[:task_id])

          if @task.assignee.id == current_user.id || can?(current_user, :update_members_task_work, user_project)
            attrs = attributes_for_keys [:remaining_estimate]
            if @task.update_attributes attrs
              present @task, with: Entities::Task
            else
              not_found!
            end
          else
            forbidden!
          end
        end
      end

      # Delete a task
      #
      # Parameters:
      #   id (required) - The ID of a project
      #   task_id (required) - The ID of a project task
      # Example Request:
      #   DELETE /projects/:id/tasks/:task_id
      delete ":id/tasks/:task_id" do
        set_current_user_for_thread do
          authorize! :delete_project_task, user_project
          task = user_project.tasks.find(params[:task_id])
          forbidden! unless task.work_logged == 0
          task.destroy
        end
      end

    end
  end
end