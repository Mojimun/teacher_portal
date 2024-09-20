Rails.application.routes.draw do
  devise_for :users, skip: [:registrations]

  devise_scope :user do
    get 'users/sign_out', to: 'users/sessions#destroy'
    authenticated :user do
      root 'students#index', as: :authenticated_root
    end
    unauthenticated do
      root to: "users/sessions#new", as: nil
    end
  end

  resources :students do
    collection do
      get 'get_all_student_list'
      delete 'delete_student'
      post 'save_mass_data_upload'
      get 'get_student_data'
    end
  end
end