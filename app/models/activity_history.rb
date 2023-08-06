# == Schema Information
#
# Table name: activity_histories
#
#  id          :bigint           not null, primary key
#  record_type :string(255)
#  record_id   :bigint
#  action      :integer          not null
#  date        :date             not null
#  description :text(65535)
#  user_id     :bigint
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
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
