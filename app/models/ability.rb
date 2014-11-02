class Ability
  class << self
    def allowed(user, subject)
      return [] unless user.kind_of?(User)

      case subject.class.name
      when "Project" then project_abilities(user, subject)
      else []
      end.concat(global_abilities(user))
    end

    def global_abilities(user)
      rules = []
      rules
    end

    def project_abilities(user, project)
      rules = []

      members = project.project_members
      member = project.project_members.find_by_user_id(user.id)

      # Rules based on role in project
      if user.admin? || members.admins.include?(member)
        rules << project_admin_rules

      elsif members.masters.include?(member)
        rules << project_master_rules

      elsif members.developers.include?(member)
        rules << project_dev_rules

      elsif members.guests.include?(member)
        rules << project_guest_rules

      end

      rules.flatten
    end


    def project_guest_rules
      [
        :read_project,
        :read_project_member
      ]
    end

    def project_dev_rules
      project_guest_rules + [
        :update_task_work,
        :take_unassigned_task
      ]
    end

    def project_master_rules
      project_dev_rules + [
        :export_project,
        :create_project_member,
        :update_project_member,
        :delete_project_member,
        :create_project_task,
        :update_project_task,
        :delete_project_task,
        :update_members_task_work
      ]
    end

    def project_admin_rules
      project_master_rules + [
        :create_project_member_admin,
        :delete_project,
        :update_project
      ]
    end
  end
end
