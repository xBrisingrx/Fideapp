Rails.application.routes.draw do
  root 'main#welcome'
  get 'main/welcome'

  namespace :authentication, path: '', as: '' do
    resources :users, only: [:index,:new, :create]
    resources :sessions, only: [:create]
    get 'login', to: 'sessions#new', as: 'login'
    get 'logout', to: 'sessions#destroy', as: 'logout'
  end

  resources :urbanizations do 
    get 'disable/:id', to: 'urbanizations#disable', as: 'disable'
  end
end
