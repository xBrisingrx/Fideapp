# == Schema Information
#
# Table name: contacts
#
#  id           :bigint           not null, primary key
#  name         :string(255)      not null
#  relationship :string(255)      not null
#  phone        :string(255)      not null
#  client_id    :bigint
#  active       :boolean          default(TRUE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class Contact < ApplicationRecord
  belongs_to :client

  validates :name,:phone, :relationship, presence: true

  scope :actives, ->{ where(active:true) }
end
