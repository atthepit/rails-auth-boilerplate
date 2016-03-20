require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RailsAuth2
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # RACK Middleware
    config.middleware.use Rack::MethodOverride          # Allows the use of the _method hack to route POST requests to other verbs.
    # config.middleware.use ActionDispatch::Cookies     # Supports the cookie method in ActionController, including support for signed and encrypted cookies.
    # config.middleware.use ActionDispatch::Flash         # Supports the flash mechanism in ActionController.
    # config.middleware.use ActionDispatch::BestStandards # Tells Internet Explorer to use the most standards-compliant available renderer. In production mode, if ChromeFrame is available, use ChromeFrame.
  end
end
