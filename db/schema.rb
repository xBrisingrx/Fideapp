# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2023_03_12_223408) do

  create_table "active_storage_attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "adjusts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci", force: :cascade do |t|
    t.decimal "value", precision: 15, scale: 2, default: "0.0"
    t.decimal "porcent", precision: 15, scale: 2, default: "0.0"
    t.boolean "active", default: true
    t.string "comment"
    t.bigint "fee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fee_id"], name: "index_adjusts_on_fee_id"
  end

  create_table "apple_projects", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "apple_id"
    t.bigint "project_id"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["apple_id"], name: "index_apple_projects_on_apple_id"
    t.index ["project_id"], name: "index_apple_projects_on_project_id"
  end

  create_table "apples", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci", force: :cascade do |t|
    t.string "code", limit: 100, null: false
    t.decimal "hectares", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "value", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "space_not_available", precision: 15, scale: 2, default: "0.0", comment: "Espacio de la manzana que no puede ser utilizado"
    t.bigint "condominium_id"
    t.bigint "sector_id"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["condominium_id"], name: "index_apples_on_condominium_id"
    t.index ["sector_id"], name: "index_apples_on_sector_id"
  end

  create_table "clients", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.string "last_name", null: false
    t.string "dni", limit: 20
    t.string "email", limit: 100
    t.string "direction"
    t.string "marital_status", limit: 30
    t.string "phone", limit: 60
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "condominia", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "currencies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci", force: :cascade do |t|
    t.string "name", limit: 40, null: false
    t.string "detail"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "need_exchange", default: false
  end

  create_table "fee_payments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "fee_id"
    t.boolean "active", default: true
    t.date "date"
    t.string "detail", default: ""
    t.string "comment"
    t.decimal "tomado_en", precision: 15, scale: 2, default: "1.0"
    t.decimal "total", precision: 15, scale: 2, default: "0.0"
    t.decimal "payment", precision: 15, scale: 2, default: "0.0", comment: "Dinero ingresado"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "payments_currency_id"
    t.string "code", default: "0"
    t.decimal "valor_acarreado", precision: 15, scale: 2, default: "0.0"
    t.index ["fee_id"], name: "index_fee_payments_on_fee_id"
    t.index ["payments_currency_id"], name: "index_fee_payments_on_payments_currency_id"
  end

  create_table "fees", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci", force: :cascade do |t|
    t.date "due_date"
    t.decimal "interest", precision: 15, scale: 2, default: "0.0", null: false, comment: "Interes"
    t.integer "number", null: false
    t.decimal "owes", precision: 15, scale: 2, default: "0.0", null: false, comment: "Lo que adeuda"
    t.date "pay_date"
    t.boolean "payed", default: false
    t.decimal "payment", precision: 15, scale: 2, default: "0.0", null: false, comment: "Valor pagado"
    t.decimal "total_value", precision: 15, scale: 2, default: "0.0", null: false, comment: "Valor inicial + ajustes + intereses"
    t.decimal "value", precision: 15, scale: 2, default: "0.0", null: false, comment: "Valor inicial"
    t.string "comment", default: ""
    t.integer "pay_status", default: 0
    t.bigint "sale_id"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sale_id"], name: "index_fees_on_sale_id"
  end

  create_table "land_projects", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "land_id"
    t.bigint "project_id"
    t.string "status"
    t.decimal "price", precision: 15, scale: 2, default: "0.0"
    t.decimal "porcent", precision: 15, scale: 2, default: "0.0"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["land_id"], name: "index_land_projects_on_land_id"
    t.index ["project_id"], name: "index_land_projects_on_project_id"
  end

  create_table "lands", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci", force: :cascade do |t|
    t.string "code", null: false, comment: "denominacion"
    t.boolean "is_corner", default: false
    t.boolean "is_green_space", default: false
    t.integer "land_type", default: 0
    t.string "measure"
    t.decimal "price", precision: 15, scale: 2, default: "0.0"
    t.decimal "space_not_available", precision: 15, scale: 2, default: "0.0", comment: "Espacio de el lote que no puede ser utilizado"
    t.integer "status", default: 0
    t.decimal "area", precision: 15, scale: 2, default: "0.0"
    t.string "ubication"
    t.bigint "apple_id"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["apple_id"], name: "index_lands_on_apple_id"
  end

  create_table "materials", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payment_methods", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payments_currencies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "payments_type_id"
    t.bigint "currency_id"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["currency_id"], name: "index_payments_currencies_on_currency_id"
    t.index ["payments_type_id"], name: "index_payments_currencies_on_payments_type_id"
  end

  create_table "payments_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "price_adjustments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci", force: :cascade do |t|
    t.date "date", null: false
    t.decimal "value", precision: 15, scale: 2, default: "0.0", null: false
    t.string "comment"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "project_materials", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "material_id"
    t.boolean "active", default: true
    t.decimal "price", precision: 15, scale: 2, default: "0.0"
    t.decimal "porcent", precision: 15, scale: 2, default: "0.0"
    t.decimal "units", precision: 15, scale: 2, default: "0.0"
    t.string "type_units", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["material_id"], name: "index_project_materials_on_material_id"
    t.index ["project_id"], name: "index_project_materials_on_project_id"
  end

  create_table "project_providers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "project_id"
    t.bigint "provider_id"
    t.bigint "payment_method_id"
    t.bigint "provider_role_id"
    t.string "type_total", comment: "El proveedor puede calcular su precio por el subtotal de la obra o por el precio valor inicial de la obra"
    t.decimal "porcent", precision: 15, scale: 2, default: "0.0", comment: "% que cobra"
    t.decimal "iva", precision: 15, scale: 2, default: "0.0"
    t.decimal "value_iva", precision: 15, scale: 2, default: "0.0", comment: "El valor en pesos del IVA"
    t.decimal "price", precision: 15, scale: 2, default: "0.0", comment: "Precio que cobra"
    t.decimal "price_calculate", precision: 15, scale: 2, default: "0.0", comment: "Precio calculado cuando el proveedor cobra por porcentaje de obra"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_method_id"], name: "index_project_providers_on_payment_method_id"
    t.index ["project_id"], name: "index_project_providers_on_project_id"
    t.index ["provider_id"], name: "index_project_providers_on_provider_id"
    t.index ["provider_role_id"], name: "index_project_providers_on_provider_role_id"
  end

  create_table "project_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "description", default: ""
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "projects", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci", force: :cascade do |t|
    t.integer "number", null: false
    t.string "name"
    t.boolean "active", default: true
    t.decimal "price", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "subtotal", precision: 15, scale: 2, default: "0.0", null: false
    t.decimal "final_price", precision: 15, scale: 2, default: "0.0", null: false
    t.integer "status", default: 0
    t.text "description"
    t.decimal "land_price", precision: 15, scale: 2, default: "0.0", null: false, comment: "Precio por lote"
    t.decimal "land_corner_price", precision: 15, scale: 2, default: "0.0", null: false, comment: "Precio por lote que es esquina"
    t.bigint "project_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_type_id"], name: "index_projects_on_project_type_id"
  end

  create_table "provider_roles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "providers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "cuit"
    t.string "description"
    t.string "activity"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sale_clients", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "sale_id"
    t.bigint "client_id"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_sale_clients_on_client_id"
    t.index ["sale_id"], name: "index_sale_clients_on_sale_id"
  end

  create_table "sale_products", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci", force: :cascade do |t|
    t.bigint "sale_id"
    t.string "product_type"
    t.bigint "product_id"
    t.text "comment"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_type", "product_id"], name: "index_sale_products_on_product_type_and_product_id"
    t.index ["sale_id"], name: "index_sale_products_on_sale_id"
  end

  create_table "sales", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci", force: :cascade do |t|
    t.boolean "status", default: false
    t.boolean "apply_arrear", default: true, null: false, comment: "Venta aplica mora"
    t.decimal "arrear", precision: 15, scale: 2, default: "0.5", null: false, comment: "% de mora"
    t.text "comment"
    t.date "date", null: false, comment: "Fecha en que se realizo la venta"
    t.integer "due_day", default: 10, null: false, comment: "Num dia de vencimiento de pagos"
    t.integer "number_of_payments", null: false, comment: "Num de cuotas inicial"
    t.decimal "price", precision: 15, scale: 2, default: "0.0", null: false, comment: "Valor inicial de venta"
    t.bigint "land_id"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["land_id"], name: "index_sales_on_land_id"
  end

  create_table "sectors", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "active", default: true, null: false
    t.decimal "size", precision: 10, default: "0", null: false
    t.bigint "urbanization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["urbanization_id"], name: "index_sectors_on_urbanization_id"
  end

  create_table "urbanizations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "active", default: true, null: false
    t.decimal "size", precision: 10, default: "0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "username", null: false
    t.string "email", null: false
    t.integer "rol", default: 1, null: false
    t.string "password_digest", null: false
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "adjusts", "fees"
  add_foreign_key "apple_projects", "apples"
  add_foreign_key "apple_projects", "projects"
  add_foreign_key "apples", "condominia"
  add_foreign_key "apples", "sectors"
  add_foreign_key "fee_payments", "fees"
  add_foreign_key "fee_payments", "payments_currencies"
  add_foreign_key "fees", "sales"
  add_foreign_key "land_projects", "lands"
  add_foreign_key "land_projects", "projects"
  add_foreign_key "lands", "apples"
  add_foreign_key "payments_currencies", "currencies"
  add_foreign_key "payments_currencies", "payments_types"
  add_foreign_key "project_materials", "materials"
  add_foreign_key "project_materials", "projects"
  add_foreign_key "project_providers", "payment_methods"
  add_foreign_key "project_providers", "projects"
  add_foreign_key "project_providers", "provider_roles"
  add_foreign_key "project_providers", "providers"
  add_foreign_key "projects", "project_types"
  add_foreign_key "sale_clients", "clients"
  add_foreign_key "sale_clients", "sales"
  add_foreign_key "sale_products", "sales"
  add_foreign_key "sales", "lands"
  add_foreign_key "sectors", "urbanizations"
end
