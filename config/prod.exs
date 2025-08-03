import Config

# Configures Swoosh API Client
config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: CopilotApi.Finch

# Disable Swoosh Local Memory Storage
config :swoosh, local: false

# Do not print debug messages in production
config :logger, level: :info, backends: [:console, LogflareLogger.HttpBackend]

# Runtime production configuration, including reading
# of environment variables, is done on config/runtime.exs.

config :logflare_logger_backend,
  api_key: System.get_env("LOGFLARE_API_KEY"),
  source_id: System.get_env("LOGFLARE_SOURCE_ID"),
  metadata: :all
