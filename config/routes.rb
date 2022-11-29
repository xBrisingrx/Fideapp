Rails.application.routes.draw do
  root 'main#welcome'
  get 'main/welcome'

  namespace :authentication do
    resource :users, only: [:index, :new, :create]
  end
end
