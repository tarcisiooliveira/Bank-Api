# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config
#
config :bank_api,
  ecto_repos: [BankApi.Repo]

# Configures the endpoint
config :bank_api, BankApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "AmwwYvJaXO247x47EcA0FYm49UKdMn/7p/FypNqrmHB7DlONoAATUosJR5GVnfmT",
  render_errors: [view: BankApiWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: BankApi.PubSub,
  live_view: [signing_salt: "zU05BQD6"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

config :bank_api, BankApiWeb.Auth.GuardianAdmin,
  issuer: "bank_api",
  secret_key: "rFNnxDmG47707Wn4UrKcR8c0M8HbPYpjjZtX4QDhXKgE01DQE9o9o+yXC/7w6BA4"

config :bank_api, BankApiWeb.Auth.GuardianUser,
  issuer: "bank_api",
  secret_key: "wF3cZjflTctAbZE2con/ZVaAQ7jocnrxfSdh9iE7oDn6zyVsdeM30TMhziuMJEgr"

config :bank_api, BankApiWeb.Auth.PipelineUser,
  module: BankApiWeb.Auth.GuardianUser,
  error_handler: BankApiWeb.Auth.ErrorHandler

config :bank_api, BankApiWeb.Auth.PipelineAdmin,
  module: BankApiWeb.Auth.GuardianAdmin,
  error_handler: BankApiWeb.Auth.ErrorHandler

config :bcrypt_elixir, log_rounds: 4

config :email_checker,
  default_dns: :system,
  also_dns: [],
  validations: [EmailChecker.Check.Format, EmailChecker.Check.MX],
  smtp_retries: 2,
  timeout_milliseconds: :infinity
