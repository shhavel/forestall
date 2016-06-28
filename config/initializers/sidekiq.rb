Sidekiq.configure_server { |config| config.redis = Settings.redis.symbolize_keys }
Sidekiq.configure_client { |config| config.redis = Settings.redis.symbolize_keys }
