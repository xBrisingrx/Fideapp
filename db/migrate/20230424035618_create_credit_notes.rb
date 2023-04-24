class CreateCreditNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :credit_notes do |t|
      t.date :date, null: false
      t.string :description, null: false
      t.references :fee_payment, foreign_key: true
      t.references :user, foreign_key: true
      t.boolean :active, default: true 

      t.timestamps
    end
  end
end
