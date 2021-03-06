# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Tzdata db config
config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

# Custom application global variables
config :home73k, :app_global_vars,
  time_zone: "America/New_York",
  blog_content: "priv/content",
  chroma_bin: "priv/go/bin/chroma"

# Configures the endpoint
config :home73k, Home73kWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "WeJCiaVAL9BVFsXVvxiv/HKOIxKM9tAOwW3fOox9KF3kMDYRjS6q+6I8Vg3TCaYE",
  render_errors: [view: Home73kWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Home73k.PubSub,
  live_view: [signing_salt: "jFCQvylC"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
