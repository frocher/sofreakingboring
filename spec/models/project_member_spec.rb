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
require 'rails_helper'

describe ProjectMember do
  describe 'Associations' do
    it { should belong_to(:project) }
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:project) }
  end
end
