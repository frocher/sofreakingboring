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
require 'rails_helper'

describe Project do
  describe 'Associations' do
    it { should have_many(:project_members).class_name('ProjectMember') }
    it { should have_many(:users).class_name('User') }
    it { should have_many(:tasks).class_name('Task') }
    it { should have_many(:project_snapshots).class_name('ProjectSnapshot') }
    it { should have_many(:project_openings).class_name('ProjectOpening') }
  end

  describe 'validations' do
    it { should validate_presence_of(:code) }
    it { should validate_uniqueness_of(:code) }
    it { should ensure_length_of(:code).is_at_most(8) }
    it { should validate_presence_of(:name) }
  end
end
