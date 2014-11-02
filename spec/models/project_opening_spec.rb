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
require 'rails_helper'

describe ProjectOpening do
  describe 'Associations' do
    it { should belong_to(:project) }
    it { should belong_to(:user) }
  end


end
