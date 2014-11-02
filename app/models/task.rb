# == Schema Information
#
# Table name: tasks
#
#  id                 :integer          not null, primary key
#  name               :string(255)      default(""), not null
#  description        :text
#  original_estimate  :integer
#  remaining_estimate :integer
#  project_id         :integer          not null
#  assignee_id        :integer
#  created_at         :datetime
#  updated_at         :datetime
#
class Task < ActiveRecord::Base
  include InternalId

  acts_as_taggable

  belongs_to :assignee, class_name: "User"
  belongs_to :project

  has_many :work_logs, dependent: :destroy

  #
  # Versioning
  #
  has_paper_trail unless: Proc.new { |t| t.project.draft? }
  
  #
  # Validation
  #
  validates :name, presence: true
  validates :original_estimate, numericality: { greater_than_or_equal_to: 0 }
  validates :remaining_estimate, numericality: { greater_than_or_equal_to: 0 }

  #
  # Scopes
  #
  scope :done, -> { where("remaining_estimate = 0") }

  def self.not_started
    all.select {|s| s.remaining_estimate != 0 && s.work_logged == 0}
  end

  def self.in_progress
    all.select {|s| s.remaining_estimate != 0 && s.work_logged != 0}
  end

  def code
    project.code + "-" + iid.to_s 
  end


  def work_logged
    count = 0
    work_logs.each do |log|
      count += log.worked
    end

    count
  end

  def delta
    original_estimate - (work_logged + remaining_estimate)
  end
end
