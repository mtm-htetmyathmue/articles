Rails.application.routes.draw do
  devise_for :users
  devise_scope :user do  
    get '/users/sign_out' => 'devise/sessions#destroy'     
  end
  resources :categories
  root "articles#index"
 
  resources :articles do
    resources :comments
  end
  
  get '/search',to: "articles#search"
  
end

