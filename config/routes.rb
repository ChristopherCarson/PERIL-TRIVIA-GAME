Rails.application.routes.draw do
  devise_for :users

  root controller: :rooms, action: :index
  
 resources :admin do
        collection do
      get :populate
    end
  end

  resources :room_messages
  
  resources :rooms do
        collection do
      get :buzzer
      get :playerReady
    end
  end
end
