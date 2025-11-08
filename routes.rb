Rails.application.routes.draw do
  root "contacts#index"

  resources :contacts do
    collection do
      post :bulk_import
      delete :clear_all
    end
  end

  resources :calls, only: [ :index, :create ] do
    collection do
      post :bulk_call
      post :ai_command
    end
  end

  # Twilio webhooks
  namespace :twilio do
    post :voice
    post :status_callback
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
