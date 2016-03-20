# Rails-auth2

Simple boilerplate to start a Rails project with `devise` for authentication and `jwt` and `cors` for api authentication.

## Get started
Run the following steps in order to get started.

First, install the gems localy with:
```sh
bundle install --path vendor/bundle
```

Then install devise:
```sh
bundle exec generate devise:install
```

Create the devise resource (`user` in this case)
```sh
bundle exec rails generate devise User
```

Migrate de database:
```sh
bundle exec rake db:migrate
```

And you can start now you dev server:
```sh
bundle exec rails s
```

## How to

TL;DR: I've just basically followed the instructions of Jim Jeffers in this video: https://www.youtube.com/watch?v=_CAq-F2icp4

First of all we have to add the gems to our `Gemfile`:
```ruby
gem 'rack-cors', :require => 'rack/cors'

gem 'devise'

gem 'jwt'
```

Then create a simple wrapper around the `JWT` gem adding some things like the expiration date to keep things dry:
```ruby
require 'jwt'

module AuthToken
  def AuthToken.encode(payload)
    payload['exp'] = 24.hours.from_now.to_i # Set expiration to 24 hours
    JWT.encode(payload, Rails.application.secrets.secret_key_base)
  end

  def AuthToken.valid?(token)
    begin
      AuthToken.decode(token)
    rescue
      false
    end
  end

  def AuthToken.decode(token)
    JWT.decode(token, Rails.application.secrets.secret_key_base)
  end
end
```

Then, override the `Devise::SessionsController` with a new controller that's able to generate the auth token and respond with `json`. Execute the following command:
```sh
bundle exec rails generate devise:controllers users
```
That will create the `app/controllers/users` folder and inside we only really need the `sessions_controller.rb` for now:
```ruby
class Users::SessionsController < Devise::SessionsController
  require 'auth_token'

  # Disable CSRF protection
  skip_before_action :verify_authenticity_token

  respond_to :html, :json

  def create

    # This is the default behavior from devise - view the sessions controller source:
    # https://github.com/platformatec/devise/blob/master/app/controllers/devise/sessions_controller.rb#L16
    self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_flashing_format?
    sign_in(resource_name, resource)
    yield resource if block_given?

    # Here we're deviating from the standard behaviour by issuing our JWT
    # to any JS based client.
    token = AuthToken.encode({ user_id: resource.id })
    respond_with resource do |format|
      format.json { render json: {user: resource.email, token: token } }
    end

    # The default behaviour would have been to simply fire respond_with:
    # respond_with resource, location: after_sign_in_path_for(resource)
  end

end
```

Once that's done we can define a filter to verify the jwt token in the `ApplicationController`:
```ruby
class ApplicationController < ActionController::Base
  require 'auth_token'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

    ##
    # This method can be used as a before filter to protect
    # any actions by ensuring the request is transmitting a
    # valid JWT
    def verify_jwt_token
      head :unauthorized if request.headers['Authorization'].nil? ||
        !AuthToken.valid?(request.headers['Authorization'].split(' ').last)
    end
end
```

And we can use it like in this `ApiController` to test it works:
```ruby
class ApiController < ApplicationController
  before_filter :verify_jwt_token

  def test
    respond_to do |format|
      format.json { render json: { 'sample' => 'data' } }
    end
  end
end
```

The last step is to configure `Rack::Cors` with an initializer:
```ruby
Rails.application.config.middleware.insert_before 0, "Rack::Cors" do
  allow do
    origins '*'
    resource '*', headers: :any, methods: [:get, :post, :put, :delete, :options]
  end
end
```
