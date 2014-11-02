module HomeHelper
  def callout
    if current_user.projects.count == 0
      description = "You don't have a project yet. You could be invited by others or " + link_to("create your own new project.", new_project_path)
      description = description.html_safe
      render partial: "shared/callout_info", locals: {title: "Welcome", description: description}
    elsif current_user.project_openings == 0
      description = "You still haven't opened any project. Just go to your " + link_to("projects page.", projects_path)
      description = description.html_safe
      render partial: "shared/callout_info", locals: {title: "Welcome", description: description}
    end
  end
end
