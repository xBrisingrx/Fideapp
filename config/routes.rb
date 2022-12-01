Rails.application.routes.draw do
  resources :lands
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
  resources :clients, except: [:destroy, :show]
  post 'disable_client', to: 'clients#disable', as: 'disable_client'
end
