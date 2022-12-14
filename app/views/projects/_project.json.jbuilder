json.extract! project, :id, :number, :name, :active, :price, :total, :status, :created_at, :updated_at
json.url project_url(project, format: :json)
