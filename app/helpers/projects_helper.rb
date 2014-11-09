module ProjectsHelper
  def dashboard_callout(project)
    if project.tasks.count == 0
      description = "Your project doesn't have any task. You should go to the " + link_to("tasks page.", project_tasks_path(project))
      description = description.html_safe
      render partial: "shared/callout_info", locals: {title: "No tasks yet", description: description}
    end
  end

  def options_for_project(project)
    if project.draft?
      ['draft', 'opened']
    else
      ['opened', 'closed']
    end
  end

  def class_for_project_state(project)
    case project.state
    when 'draft'
      'warning'
    when 'opened'
      'success'
    else
      'danger'
    end
  end

  def members_done(project)
    members_done = "["
    project.project_members.by_name.each do |member|
      if member.work_logged > 0 || member.remaining_estimate > 0
        members_done << ","  unless members_done == "["
        name = escape_javascript(member.name)
        members_done << "[#{to_days(member.work_logged)}, '#{name}']"
      end
    end
    members_done << "]"
  end

  def members_remaining(project)
    members_tbd  = "["
    project.project_members.by_name.each do |member|
      if member.work_logged > 0 || member.remaining_estimate > 0
        members_tbd << ","  unless members_tbd == "["
        name = escape_javascript(member.name)
        members_tbd  << "[#{to_days(member.remaining_estimate)}, '#{name}']"
      end
    end
    members_tbd  << "]"
  end

  def tags_done(project)
    worked = Hash.new
    project.tasks.each do |task|
      task.tag_list.each do |tag|
        val = worked[tag] || 0
        val += task.work_logged
        worked[tag] = val
      end
    end

    tags_done = "["
    worked.sort.each do |key,value|
      name = escape_javascript(key)
      tags_done << "," unless tags_done == "["
      tags_done << "[#{to_days(value)}, '#{name}']"
    end
    tags_done << "]"
  end

  def tags_remaining(project)
    remaining = Hash.new
    project.tasks.each do |task|
      task.tag_list.each do |tag|
        val = remaining[tag] || 0
        val += task.remaining_estimate
        remaining[tag] = val
      end
    end

    tags_tbd = "["
    remaining.sort.each do |key,value|
      name = escape_javascript(key)
      tags_tbd << "," unless tags_tbd == "["
      tags_tbd << "[#{to_days(value)}, '#{name}']"
    end
    tags_tbd << "]"
  end

  def user_role(project)
    member = project.find_member(current_user)
    member.nil? ? '' : member.role
  end


  def to_days(seconds)
    to_day = 60 * 8
    (Float(seconds) / to_day).round(1)
  end

  def to_date(day)
    DateTime.strptime(day, "%Y%m%d")
  end

end
