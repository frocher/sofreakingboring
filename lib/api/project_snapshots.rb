module API
  # ProjectSnapshots API
  class ProjectSnapshots < Grape::API
    before { authenticate! }

    resource :projects do

      # Get a list of project snapshots
      #
      # Parameters:
      #   id (required) - The ID of a project
      # Example Request:
      #   GET /projects/:id/snapshots
      get ":id/snapshots" do
        authorize! :read_project, user_project        
        present paginate(user_project.project_snapshots), with: Entities::ProjectSnapshot
      end

    end
  end
end