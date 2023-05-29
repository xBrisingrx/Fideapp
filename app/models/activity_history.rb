# == Schema Information
#
# Table name: activity_histories
#
#  id          :bigint           not null, primary key
#  action      :integer          not null
#  date        :date             not null
#  description :text(65535)
#  record_type :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  record_id   :bigint
#  user_id     :bigint
#
# Indexes
#
#  index_activity_histories_on_record_type_and_record_id  (record_type,record_id)
#  index_activity_histories_on_user_id                    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class ActivityHistory < ApplicationRecord
  belongs_to :record, polymorphic: true
  belongs_to :user

  validates :date, :action, presence: true

  enum action: {
    create_record: 1, 
    update_record: 2,
    disable: 3,
    enable: 4
  }
end
