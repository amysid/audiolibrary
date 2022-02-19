Rails.application.routes.draw do
 
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
 root 'sessions#new'
 
 resources :sessions
 resources :homes
 resources :books
 resources :booths
 resources :operations
 resources :categories
end
