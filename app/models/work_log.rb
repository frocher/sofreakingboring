# == Schema Information
#
# Table name: work_logs
#
#  id          :integer          not null, primary key
#  description :string(255)
#  day         :string(255)
#  worked      :integer
#  task_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class WorkLog < ActiveRecord::Base
  belongs_to :task

  validates :day, presence: true
  validates :worked, numericality: { greater_than_or_equal_to: 0 }
end
