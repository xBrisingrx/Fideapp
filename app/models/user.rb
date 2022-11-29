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

	validate :name, presence: true
	validate :username, presence: true, uniqueness: { case_sensitive: false, message: "Este usuario ya se encuentra registrado" }
	validate :password, presence: true, uniqueness: true, length: { minimum: 6 }
	validates :email, presence: true, uniqueness: { case_sensitive: false, message: "Este email ya se encuentra en uso" }

end
