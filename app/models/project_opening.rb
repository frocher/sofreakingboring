# == Schema Information
#
# Table name: project_openings
#
#  id         :integer          not null, primary key
#  project_id :integer          not null
#  user_id    :integer          not null
#  touched    :integer
#  created_at :datetime
#  updated_at :datetime
#

class ProjectOpening < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
end
