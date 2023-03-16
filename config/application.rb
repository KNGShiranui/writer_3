require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Writer3
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1
    # TODO:次の行の挿入で解決。ActiveSupport::TimeWithZone, ActiveSupport::TimeZoneが必要だったらしい。
    config.active_record.yaml_column_permitted_classes = [Symbol, Date, Hash, Array, ActiveSupport::HashWithIndifferentAccess, ActiveSupport::TimeWithZone, ActiveSupport::TimeZone, Time]
    # TODO:以下2行はいらないみたい
    # config.active_record.use_yaml_unsafe_load
    # config.active_support.use_yaml_unsafe_load

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
