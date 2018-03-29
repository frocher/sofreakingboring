module Projects::TasksHelper
  def tasks_callout(project)
    if project.tasks.count == 0
      description = "To create a new task, just clic on the 'Add Task' button. It will create a new line. "
      description << "You can then complete task informations. For estimates, you can enter time in years (e.g., 1y), months (e.g., 3mo), days (e.g., 1d), hours (e.g., 4h) or minutes (e.g., 30m), "
      description << "and of course combine them (e.g., 1y 3mo 1d 4h 30m)."
      description = description.html_safe
      render partial: "shared/callout_info", locals: {title: "No tasks yet", description: description}
    end
  end
end
