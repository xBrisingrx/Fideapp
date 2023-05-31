class AddCommentToInterests < ActiveRecord::Migration[5.2]
  def change
    add_column :interests, :comment, :text
  end
end
