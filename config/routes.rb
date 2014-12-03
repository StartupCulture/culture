Rails.application.routes.draw do

  # Initial page
  root 'pages#home'

  # Users
  devise_for :users, :controllers => { omniauth_callbacks: 'omniauth_callbacks'  }
  get '/timeline' => 'users#timeline', as: :timeline
end
