Rails.application.routes.draw do
  root 'sessions#index'

  concern :card_owner do
    resources :cards, except: [:edit, :update]
  end

  resources :articles, except: [:edit]
  resources :locations
  resources :payments, only: [:index]
  resources :points
  resources :positions, except: [:edit]
  resource :session, path: 'login', except: [:show, :new, :edit] do
    get '/', action: 'new', on: :collection, as: :new
  end
  resources :shows, shallow: true do
    resources :attendees, controller: 'users'
    resources :staffs
    resources :booths, shallow: true do
      resources :fees, only: [:new, :create, :destroy]
      resources :payments, except: [:index, :edit] do
        post 'pay', on: :member
      end
      get 'addons', on: :member
      get 'billing', on: :member
      get ':door', action: 'door', door: /[0-9A-Z]/, on: :collection
      get 'paper-signs', as: :paper_signs, on: :collection
      get 'search', on: :collection
    end
    resources :job_applications, except: [:edit]
    resources :passes, controller: 'tickets', free: true, except: [:show, :edit] do
      get 'link', on: :collection
    end
    resources :packages do
      get 'vendors', on: :collection
    end
    resources :prizes
    resources :shifts, except: [:new, :edit] do
      get 'schedule', on: :collection
      get 'timesheet', on: :collection
    end
    resources :signs
    resources :tickets, except: [:show, :edit]
  end
  resources :subscriptions, except: [:edit] do
    post 'pay', on: :member
  end
  resources :texts, except: [:edit, :update, :destroy] do
    get 'conversations', on: :collection
  end
  resources :transfers, except: [:show, :edit, :update]
  resources :users, concerns: [:card_owner], except: [:index] do
    get 'login', on: :member
  end
  resources :vendors, concerns: [:card_owner], shallow: true do
    resources :contacts, controller: 'users', only: [:new, :create]
    resources :offers, except: [:show, :new, :edit]
    resources :payments, only: [:new, :create]
    resources :testimonials, except: [:show, :new, :edit]
    get 'merge', on: :member
    post 'merge', action: 'merge_into', on: :member
  end

  get 'search(/:filter)' => 'search#index', :as => :search
  get 'settings' => 'settings#index', :as => :settings
  post 'preview' => 'settings#preview'

  post 'webhooks/stripe' => 'webhooks#stripe'
  post 'webhooks/twilio' => 'webhooks#twilio'


  get 'user_email' => 'users#user_email'
  get 'sync_cm_task' => 'users#sync_cm_task'
  get 'get_staff_list' => 'users#get_staff_list'

  #resources :staffs

end
