# == Schema Information
#
# Table name: projects
#
#  id                      :integer          not null, primary key
#  code                    :string(255)      default(""), not null
#  name                    :string(255)      default(""), not null
#  description             :text
#  created_at              :datetime
#  updated_at              :datetime
#  attachment_file_name    :string(255)
#  attachment_content_type :string(255)
#  attachment_file_size    :integer
#  attachment_updated_at   :datetime
#  state                   :string(255)
#

class Project < ActiveRecord::Base
  has_attached_file :attachment, :styles => { :medium => "160x180#", :thumb => "100>", :small_thumb => "50x50#" }

  has_many :project_members, dependent: :destroy
  has_many :users, through: :project_members
  has_many :tasks, dependent: :destroy
  has_many :project_snapshots, dependent: :destroy
  has_many :project_openings, dependent: :destroy


  #
  # Validations
  #
  validates :code, presence: true
  validates_uniqueness_of :code
  validates_length_of :code, :maximum => 8
  validates :name, presence: true
  validates_attachment_content_type :attachment, :content_type => /\Aimage/
  validates_attachment_size :attachment, :in => 0.kilobytes..200.kilobytes

  #
  # States
  #
  state_machine :state, initial: :draft do
    event :openit do
      transition all => :opened
    end

    event :closeit do
      transition :opened => :closed
    end
  end

  #
  # Scopes
  #
  scope :opened, -> { where(state: "opened") }

  def picture_url
    attachment.url
  end

  def original_estimate
    tasks.sum(:original_estimate)
  end

  def work_logged
    resu = 0
    tasks.each do |task|
      resu += task.work_logged
    end
    return resu
  end

  def delta
    resu = 0
    tasks.each do |task|
      resu += task.delta
    end
    return resu
  end

  def remaining_estimate
    tasks.sum(:remaining_estimate)
  end

  def total
    work_logged + remaining_estimate
  end

  def progress
    total > 0 ? work_logged * 100 / total : 0
  end

  def touch_opening(user_id)
    opening = project_openings.find_by user_id: user_id
    unless opening
      opening = ProjectOpening.new
      opening.user_id    = user_id
      opening.project_id = id
    end
    opening.touched = Random.rand(9999)
    opening.save
  end

  def find_member(user)
    project_members.find_by(user_id:user.id)
  end

  # Create a snapshot of all opened projects
  def self.snapshot
    Project.opened.each do |project|
      snap = ProjectSnapshot.new
      snap.project            = project
      snap.task_count         = project.tasks.count
      snap.original_estimate  = project.original_estimate
      snap.work_logged        = project.work_logged
      snap.remaining_estimate = project.remaining_estimate
      unless snap.save
        logger.error snap.errors.messages
      end
    end
  end

end
