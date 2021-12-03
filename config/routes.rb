Rails.application.routes.draw do
  
  get 'password_resets/new'
  get 'password_resets/edit'
  root 'static_pages#home'
  
  get '/help',       to: 'static_pages#help'
  get '/about',      to: 'static_pages#about'
  get '/contact',    to: 'static_pages#contact'
  get '/privacy',    to: 'static_pages#privacy'
  get '/terms',      to: 'static_pages#terms'
  
  get '/signup',     to: 'users#new'

  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

  post '/payment_system/vZ692SnI2btP1aybeJDA4TPTmEslSjOD', to: 'payments#webhook'
  
  resources :users
  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]

  resources :emails
  resources :posts
  resources :faxes
  
  resources :recipients
  resources :senders
  resources :letters

  post 'send_communication', to: 'send_communication#send_communication'

  get 'govlookup',   to: 'recipients#lookup'
  get 'find_policy', to: 'letters#find_policy'

  post 'create-payment-intent', to: 'static_pages#create_payment_intent'
  get 'create-payment-intent', to: 'static_pages#create_payment_intent'
end
