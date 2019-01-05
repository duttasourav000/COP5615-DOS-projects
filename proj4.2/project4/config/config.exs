# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :project4, Project4Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "DxI8U0DKwCh+3u+6k1EmMBP0n0jzJ2s04CUIxr58c+PZzxUPoOe6Mwm6RvPKmuUh",
  render_errors: [view: Project4Web.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Project4.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
