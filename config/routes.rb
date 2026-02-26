Rails.application.routes.draw do
  devise_for :users

  root "home#index"

  resources :plants
  resources :consumable_items do
    resources :stock_lots, only: %i[new create], path: "stock"
  end
  resources :stock_lots, only: %i[index edit update destroy]
  resources :animals do
    resources :consumption_rules, only: %i[new create edit update destroy], shallow: true
  end


  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
