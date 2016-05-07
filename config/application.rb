require File.expand_path('../boot', __FILE__)

require 'action_controller/railtie'
require 'sprockets/railtie'
require 'action_mailer/railtie'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

Bundler.setup

module BlockBrowser
  class Application < Rails::Application


    begin
      ::BB_CONFIG = YAML::load_file(File.join(Rails.root, "config/application.yml"))
      Bitcoin::network = BB_CONFIG["network"]
      backend, db = BB_CONFIG["database"].split("::")
      ::STORE = Bitcoin::Blockchain.create_store(backend, db: db, index_nhash: true, index_p2sh_type: true)
    rescue
      p $!
      puts "Error loading configuration from config/application.yml; falling back to defaults"
      ::BB_CONFIG = YAML::load_file(File.join(Rails.root, "config/application.yml.sample"))
    end

    ::WS_CONFIG = BB_CONFIG["websocket"]

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    if BB_CONFIG['mailer']
      config.action_mailer.delivery_method = :smtp
      config.action_mailer.perform_deliveries = true
      config.action_mailer.raise_delivery_errors = true
      config.action_mailer.default_options = { from: BB_CONFIG['mailer']['from'] }
      config.action_mailer.smtp_settings = BB_CONFIG['mailer'].symbolize_keys
    end

  end
end
