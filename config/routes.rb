Rails.application.routes.draw do
  root 'main#welcome'
  get 'main/welcome'

  namespace :authentication, path: '', as: '' do
    resources :users, only: [:index,:new, :create]
    resources :sessions, only: [:new, :create]
  end
end
