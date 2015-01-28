module API
  # Projects API
  class Projects < Grape::API
    before { authenticate! }

    resource :projects do

      # Get a projects list for authenticated user
      #
      # Example Request:
      #   GET /projects
      get do
        allAsked = 

        if current_user.is_admin? && params[:admin] == 'true'
          @projects = paginate Project.all
        else
          @projects = paginate current_user.projects
        end
        present @projects, with: Entities::Project
      end

      # Get recent projects list for authenticated user
      #
      # Example Request:
      #   GET /projects/recents
      get "recents" do
        recent_openings = paginate current_user.project_openings
        @projects = Array.new
        recent_openings.each do |recent|
          @projects << recent.project
        end
        present @projects, with: Entities::Project
      end

      # Get a single project
      #
      # Parameters:
      #   id (required) - The ID of a project
      # Example Request:
      #   GET /projects/:id
      get ":id" do
        authorize! :read_project, user_project        
        present user_project, with: Entities::Project, user: current_user
      end
    end
  end
end