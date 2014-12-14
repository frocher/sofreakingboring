module API
  # Users API
  class Users < Grape::API
    before { authenticate! }

    helpers do       
      def entity
        current_user.is_admin? ? Entities::AdminUser : Entities::User
      end
    end

    resource :users do
      # Get a users list
      #
      # Example Request:
      #  GET /users
      get do
        @users = User.all
        @users = @users.search(params[:search]) if params[:search].present?
        @users = paginate @users
        present @users, with: entity
      end

      # Get a single user
      #
      # Parameters:
      #   id (required) - The ID of a user
      # Example Request:
      #   GET /users/:id
      get ":id" do
        @user = User.find(params[:id])
        present @user, with: entity
      end
    end
  end
end