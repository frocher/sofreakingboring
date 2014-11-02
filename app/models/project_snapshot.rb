# == Schema Information
#
# Table name: project_snapshots
#
#  id                 :integer          not null, primary key
#  project_id         :integer          not null
#  task_count         :integer
#  original_estimate  :integer
#  work_logged        :integer
#  remaining_estimate :integer
#  created_at         :datetime
#  updated_at         :datetime
#
class ProjectSnapshot < ActiveRecord::Base

  belongs_to :project


  def delta
    original_estimate - (work_logged + remaining_estimate)
  end
end
