module API
  module Entities
    class User < Grape::Entity
      expose :id, :email, :name, :bio, :created_at
      expose :is_admin?, as: :is_admin
      expose :avatar_url
    end

    class AdminUser < User
      expose :current_sign_in_at, :sign_in_count, :current_sign_in_ip
    end

    class Project < Grape::Entity
      expose :id, :code, :name, :description, :picture_url, :created_at, :original_estimate, :work_logged, :remaining_estimate, :delta
    end

    class ProjectMember < Grape::Entity
      expose :id, :project_id, :user_id, :username, :role, :created_at
    end

    class ProjectSnapshot < Grape::Entity
      expose :id, :project_id, :task_count, :original_estimate, :work_logged, :remaining_estimate, :delta, :created_at
    end

    class Task < Grape::Entity
      format_with :to_s do |tags|
        tags.to_s
      end

      expose :id, :project_id, :assignee_id, :code, :iid, :name, :description, :original_estimate, :remaining_estimate, :work_logged, :delta, :created_at, :updated_at
      expose :tag_list, format_with: :to_s
    end

    class TimesheetTask < Grape::Entity
      expose :id, :code, :name, :description, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday, :original_estimate, :remaining_estimate, :work_logged, :delta
    end

    class WorkLog < Grape::Entity
      expose :id, :task_id, :description, :day, :worked, :created_at
    end
  end
end