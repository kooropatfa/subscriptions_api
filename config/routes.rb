Rails.application.routes.draw do
  use_doorkeeper do
    skip_controllers :applications, :authorized_applications
  end

  scope module: :api, defaults: { format: :json }, path: :api do
    scope module: :v1, path: :v1 do
      devise_for :users, controllers: {
           registrations: 'api/v1/users/registrations',
      }, skip: [:sessions, :password]

      resource :purchase, only: [:create]
    end
  end
end
