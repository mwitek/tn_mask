Rails.application.routes.draw do
  root to: 'home#index'# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post '/provision_number', to: 'home#create', as: :provision_number
  post '/make_call', to: 'home#make_call', as: :make_call
  delete '/release_number', to: 'home#release_number', as: :release_number
end
