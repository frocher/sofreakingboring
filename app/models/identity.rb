# == Schema Information
#
# Table name: identities
#
#  id         :integer          not null, primary key
#  provider   :string(255)      not null
#  uid        :string(255)      not null
#  user_id    :integer          not null
#  created_at :datetime
#  updated_at :datetime
#

class Identity < ActiveRecord::Base
  belongs_to :user
end
