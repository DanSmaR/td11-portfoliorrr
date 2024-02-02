Rails.application.routes.draw do
  devise_for :users, :controllers => {:registrations => "registrations"}

  root to: "home#index"

  resources :projects, only: %i[index]

  resources :job_categories, only: %i[index create destroy]
  resources :profiles, only: [] do
    get 'search', on: :collection
  end

  resources :posts, only: %i[new create] do
    resources :comments, only: %i[create]
    post 'pin', on: :member
  end

  resources :users, only: [] do
    resources :posts, shallow: true, only: %i[show edit update]
    resources :profiles, shallow: true, only: %i[edit show update] do
      patch :remove_photo, on: :member
      resources :connections, only: %i[create index] do
        patch 'unfollow', 'follow_again'
      end
      get 'following', controller: 'connections'
    end
  end

  patch 'work_unavailable', controller: :profiles
  patch 'open_to_work', controller: :profiles

  resources :likes, only: %i[create destroy]
  resources :job_categories, only: %i[index create]
  resource :profile, only: %i[edit update], controller: :profile, as: :user_profile do
    resources :professional_infos, shallow: true, only: %i[new create edit update]
    resources :education_infos, shallow: true, only: %i[new create edit update]
  end

  resources :profile_job_categories, only: %i[new create]

  namespace :api do
    namespace :v1 do
      resources :projects, only: %i[index]
      resources :job_categories, only: %i[index]
      resources :profiles, only: [] do
        get 'search', on: :collection
      end

      resources :invitations, only: %i[create update]
    end
  end
end
