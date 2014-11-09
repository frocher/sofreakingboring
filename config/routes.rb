require 'api/api'

Olb::Application.routes.draw do
  
  # API
  API::API.logger Rails.logger
  mount API::API => '/api'

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }
  
  root :to => 'home#index'

  get "/404", :to => "errors#not_found"
  get "/500", :to => "errors#internal_error"

  get "/work_for_period" => 'home#work_for_period', as: 'work_for_period'

  resource :profile, only: [:show, :edit, :update] do
    scope module: :profiles do
      resource :avatar, only: [:destroy]
      resource :password, only: [:edit, :update]
    end
  end

  resources :projects do
    put :remove_attachment
    get :show_export
    get :export
    scope module: :projects do
      resources :members
      resources :tasks
      resource  :timesheet do
        get :tasks
      end
    end
  end

  namespace :admin do
    resources :projects, only: [:index]
    resources :users do
      put :remove_avatar
    end
    resources :settings, only: [:index, :edit]
  end
end
