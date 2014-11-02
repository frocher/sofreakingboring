# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  name                   :string(255)      default(""), not null
#  bio                    :string(255)      default(""), not null
#  avatar_file_name       :string(255)
#  avatar_content_type    :string(255)
#  avatar_file_size       :integer
#  avatar_updated_at      :datetime
#  admin                  :boolean          default(FALSE), not null
#  authentication_token   :string(255)
#

class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :timeoutable,
         :omniauthable, :omniauth_providers => [:facebook, :google_oauth2, :github]

  before_save :ensure_authentication_token
  alias_attribute :private_token, :authentication_token

  has_attached_file :avatar, :styles => { :medium => "165x165#", :thumb => "100x100#" }, :default_url => "/images/avatar_missing.png"

  has_many :identities

  has_many :project_members, dependent: :destroy
  has_many :project_openings, dependent: :destroy

  has_many :projects, through: :project_members
  has_many :tasks, :foreign_key => 'assignee_id'

  # Scopes
  scope :admins, -> { where(admin: true) }

  #
  # Validations
  #
  validates :name, presence: true, uniqueness: true
  validates :bio, length: { maximum: 500 }, allow_blank: true         
  validates_attachment_content_type :avatar, :content_type => /\Aimage/
  validates_attachment_size :avatar, :in => 0.megabytes..100.kilobytes

  def is_admin?
    admin
  end

  def attributes
    super.merge({'avatar_url' => avatar_url})
  end

  def avatar_url
    ApplicationController.helpers.avatar_icon(email)
  end

  def ensure_authentication_token
    self.authentication_token ||= generate_authentication_token
  end

  def work_logged
    WorkLog.joins(task: :assignee).select("sum(worked) as work_sum").where(tasks:{assignee_id:id}).take.work_sum || 0
  end

  def work_week(period_start, period_end)
    day_start = period_start.strftime("%Y%m%d")
    day_end   = period_end.strftime("%Y%m%d")
    logs = WorkLog.joins(task: :project).select("project_id, projects.name as name, day, sum(worked) as total_worked").where(day:day_start..day_end).where(tasks:{assignee_id:id}).group("project_id, projects.name, day")
    WorkWeek.new(logs)
  end

  #
  # Class methods
  #
  class << self
    def search query
      where("lower(name) LIKE :query OR lower(email) LIKE :query", query: "%#{query.downcase}%")
    end

    def from_omniauth(auth)
      user = nil
      identity = Identity.where(provider: auth.provider, uid: auth.uid).first
      if identity
        user = identity.user
      else
        user = User.find_by(email: auth.info.email) || User.create(email: auth.info.email, password: Devise.friendly_token[0,20], name: (auth.info.name || auth.info.full_name).to_s)
        identity = Identity.create(provider: auth.provider, uid: auth.uid, user: user)
      end
      user
    end

  end

  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end
end
