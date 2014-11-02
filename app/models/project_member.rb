# == Schema Information
#
# Table name: project_members
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  project_id :integer          not null
#  role       :integer          default(0), not null
#  created_at :datetime
#  updated_at :datetime
#

class ProjectMember < ActiveRecord::Base
  enum role: {guest: 0, developer: 1, master: 2, admin: 3}

  belongs_to :user
  belongs_to :project

  delegate :name, to: :user
  delegate :email, to: :user

  validates :user, presence: true
  validates :project, presence: true
  validates :user_id, uniqueness: { scope: [:project_id], message: "already exists in project" }

  scope :by_name, ->    { joins(:user).order('LOWER(users.name)') }
  scope :guests, ->     { where("role = :role", role: 0) }
  scope :developers, -> { where("role = :role", role: 1) }
  scope :masters, ->    { where("role = :role", role: 2) }
  scope :admins, ->     { where("role = :role", role: 3) }


  def assigned_tasks
    Task.where("assignee_id=? and project_id=?", user.id, project.id)
  end

  def work_logged
    WorkLog.joins('INNER JOIN tasks ON work_logs.task_id = tasks.id').joins('INNER JOIN projects ON tasks.project_id = projects.id').select("sum(worked) as work_sum").where(tasks:{assignee_id:user.id}).where(projects:{id:project.id}).take.work_sum || 0
  end

  def remaining_estimate
    Task.joins('INNER JOIN projects ON tasks.project_id = projects.id').select("sum(remaining_estimate) as remaining_sum").where(tasks:{assignee_id:user.id}).where(projects:{id:project.id}).take.remaining_sum || 0
  end

  def username
    user.name
  end
end
