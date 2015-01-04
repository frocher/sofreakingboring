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
#  sign_in_count          :integer          default("0"), not null
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
#  admin                  :boolean          default("f"), not null
#  authentication_token   :string(255)
#

require 'rails_helper'

describe User do
  describe 'Associations' do
    it { should have_many(:identities).class_name('Identity') }
    it { should have_many(:project_members).class_name('ProjectMember') }
    it { should have_many(:project_openings).class_name('ProjectOpening') }
    it { should have_many(:projects).class_name('Project') }
    it { should have_many(:tasks).class_name('Task') }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should ensure_length_of(:bio).is_at_most(500) }
  end

  describe 'Respond to' do
    it { should respond_to(:is_admin?) }
    it { should respond_to(:private_token) }
  end

  describe 'authentication token' do
    it "should have authentication token" do
      user = create(:user)
      expect(user.authentication_token).not_to be_blank
    end
  end

  describe 'admin creation' do
    it "should be admin" do
      user = create(:admin)
      expect(user.is_admin?).to be true
    end
  end

  describe '#work_logged' do
    it 'should have no work logged' do
      user = create(:user)
      expect(user.work_logged).to be 0
    end

    it 'should have work' do
      work = create(:work_log)
      user = work.task.assignee
      expect(user.work_logged).not_to be 0
    end

  end

  describe '.search' do
    it 'should work' do
      result = User.search('foo')
      expect(result).to_not be_nil
    end
  end
end
