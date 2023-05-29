class CreateActivityHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :activity_histories do |t|
      t.references :record, polymorphic: true
      t.integer :action, null: false
      t.date :date, null: false
      t.text :description
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
