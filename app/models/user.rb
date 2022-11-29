# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  active          :boolean          default(TRUE)
#  email           :string(255)      not null
#  name            :string(255)      not null
#  password_digest :string(255)      not null
#  rol             :integer          not null
#  username        :string(255)      not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class User < ApplicationRecord
	has_secure_password

	validates :name, presence: true
	validates :username, presence: true, 
		uniqueness: { case_sensitive: false, message: "Este usuario ya se encuentra registrado" },
    length: { in: 3..15 },
    format: {
      with: /\A[a-z-0-9-A-Z]+\z/,
      message: :invalid
    }
	validates :password, presence: true, uniqueness: true, length: { minimum: 6 }
	validates :email, presence: true, 
		uniqueness: { case_sensitive: false, message: "Este email ya se encuentra en uso" },
    format: {
      with: /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i,
      message: :invalid
    }

  before_save :downcase_attributes

  private

  def downcase_attributes
    self.username = username.downcase
    self.email = email.downcase
  end

end
