Rails.application.routes.draw do
  match "/404", via: :all, to: "errors#not_found"
  match "/500", via: :all, to: "errors#internal_server_error"
  
  resources :refinancied_sales, only: [:index, :new, :create]
  resources :payments
  resources :credit_notes
  get 'fee_payments/new'
  get 'fee_payments/create'
  resources :payment_methods
  resources :provider_roles
  resources :projects
  root 'main#welcome'
  get 'main/welcome'

  namespace :authentication, path: '', as: '' do
    resources :users, only: [:index,:new, :create]
    resources :sessions, only: [:create]
    get 'login', to: 'sessions#new', as: 'login'
    get 'logout', to: 'sessions#destroy', as: 'logout'
  end

  resources :urbanizations, except: [:destroy, :show]
  post 'disable_urbanization', to: 'urbanizations#disable', as: 'disable_urbanization'
  resources :sectors, except: [:destroy, :show]
  post 'disable_sector', to: 'sectors#disable', as: 'disable_sector'
  resources :condominia, except: [:destroy, :show]
  post 'disable_condominium', to: 'condominia#disable', as: 'disable_condominium'
  resources :apples, except: [:destroy, :show] do 
    resources :lands, except: [:show, :destroy]
  end
  post 'disable_apple', to: 'apples#disable', as: 'disable_apple'
  post 'disable_land', to: 'lands#disable', as: 'disable_land'
  resources :clients, except: [:destroy, :show] do
    resources :contacts,  except: [:destroy, :show] do 
      get "modal_disable", on: :member
      post "disable", on: :member
    end
  end
  post 'disable_client', to: 'clients#disable', as: 'disable_client'
  resources :providers, except: [:destroy, :show]
  post 'disable_provider', to: 'providers#disable', as: 'disable_provider'
  resources :materials, except: [:destroy, :show]
  post 'disable_material', to: 'materials#disable', as: 'disable_material'
  resources :sales, except: [:show] do 
    get 'payment_summary', on: :member
  end
  post 'disable_sale', to: 'sales#disable', as: 'disable_sale'
  resources :project_types
  post 'disable_project_type', to: 'project_types#disable', as: 'disable_project_type'
  # detalle de las ventas de un lote (venta de tierra y projectos)
  get 'detail_sales', to: 'lands#detail_sales', as: 'land_detail_sales'
  get '/sectors/filter_for_urbanization/:urbanization_id', to: 'sectors#filter_for_urbanization'
  get '/apples/filter_for_sector/:sector_id', to: 'apples#filter_for_sector'

  # Fees routes
  # get 'fees/:sale_id', to: 'fees#index'
  get 'detalle_pagos/:id', to: 'fees#details', as: 'detalle_pagos'
  get 'partial_payment/:fee_id', to: 'fee_payments#new', as: 'pago_parcial'
  resources :fees, only: [:show,:create, :new, :update] do
    get 'partial_payment/:fee_id', to: 'fee_payments#new', as: 'partial_payment'
    post 'partial_payment', to: 'fee_payments#create', as: 'register_partial_payment'
    resources :fee_payments
  end
  # End fees routes 

  post '/sale_project', to: "sales#sale_project", as: 'sale_project'

  post 'disable_fee_payment', to: 'fee_payments#disable', as: 'disable_fee_payment'


  get 'fees/modal_apply_adjust/:sale_id', to: "fees#modal_apply_adjust", as: 'modal_apply_adjust'
  post 'fees/apply_adjust', to: "fees#apply_adjust", as: 'apply_adjust'

  resources :payments_types
  resources :currencies
  resource :payments_currencies
end
