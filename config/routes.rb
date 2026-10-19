Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      get "dashboard", to: "dashboard#index"

      resources :departments
      resources :employees do
        resource :salary_structure, only: %i[show update]
        member do
          get :payslips
        end
      end

      resources :payroll_runs do
        member do
          post :process_run
          patch :update_status
        end
      end

      resources :payslips, only: %i[index show update]
    end
  end
end
