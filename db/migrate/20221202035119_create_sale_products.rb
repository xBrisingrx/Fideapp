class CreateSaleProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :sale_products do |t|
      t.references :sale, foreign_key: true
      t.references :product, polymorphic: true
      t.text :comment
      t.boolean :active, default: true
      
      t.timestamps
    end
  end
end
