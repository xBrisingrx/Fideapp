class AddFeeToInterest < ActiveRecord::Migration[5.2]
  def change
    add_reference :interests, :fee, foreign_key: true
  end
end
