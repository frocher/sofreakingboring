module API
  # ProjectMembers API
  class ProjectMembers < Grape::API
    before { authenticate! }

    resource :projects do

      # Get a list of project members
      #
      # Parameters:
      #   id (required) - The ID of a project
      # Example Request:
      #   GET /members/:id/tasks
      get ":id/members" do
        authorize! :read_project_member, user_project
        present paginate(user_project.project_members), with: Entities::ProjectMember
      end

      # Get a single project member
      #
      # Parameters:
      #   id (required) - The ID of a project
      #   member_id (required) - The ID of a project member
      # Example Request:
      #   GET /projects/:id/members/:member_id
      get ":id/members/:member_id" do
        authorize! :read_project_member, user_project
        @member = user_project.project_members.find(params[:member_id])
        present @member, with: Entities::ProjectMember
      end

      # Create a new project member
      #
      # Parameters:
      #   id (required) - The ID of a project
      #   user_id (required) - The id of a user
      #   role (required) - The role of the member
      # Example Request:
      #   POST /projects/:id/members
      post ":id/members" do
        set_current_user_for_thread do
          required_attributes! [:name]
          authorize! :create_project_member, user_project
          attrs = attributes_for_keys [:user_id, :role]
          @member = user_project.project_members.new attrs
          if @member.save
            present @member, with: Entities::ProjectMember
          else
            not_found!
          end
        end
      end

      # Update an existing project member
      #
      # Parameters:
      #   id (required) - The ID of a project
      #   member_id (required) - The ID of a project member
      #   role (optional) - The role of the member
      # Example Request:
      #   PUT /projects/:id/members/:member_id
      put ":id/members/:member_id" do
        set_current_user_for_thread do
          authorize! :update_project_member, user_project
          @member = user_project.project_members.find(params[:member_id])

          attrs = attributes_for_keys [:role]

          if @member.update_attributes attrs
            present @member, with: Entities::ProjectMember
          else
            not_found!
          end
        end
      end


      # Delete a project member
      #
      # Parameters:
      #   id (required) - The ID of a project
      #   member_id (required) - The ID of a project member
      # Example Request:
      #   DELETE /projects/:id/members/:member_id
      delete ":id/members/:member_id" do
        set_current_user_for_thread do
          authorize! :delete_project_member, user_project
          member = user_project.project_members.find(params[:member_id])
          if member.work_logged == 0
            member.destroy
          else
            render_api_error!("Can't delete member with work logged", 403)
          end
        end
      end

    end
  end
end