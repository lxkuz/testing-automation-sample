Rails.application.routes.draw do
  devise_for :users

  namespace :admin do
    resources :posts do
      collection do
        get :collection_test
      end

      member do
        get :member_test
      end
    end
  end

  root to: 'admin/posts#index'
end
