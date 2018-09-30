# dev configuration
use Mix.Config

config :logger,
  backends: [:console]

config :logger, :console,
  format: {YnabApi.LogFormatter, :format},
  metadata: [:module]
