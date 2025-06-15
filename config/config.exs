import Config

config :phoenix_liveview_demo,
  ecto_repos: [PhoenixLiveviewDemo.Repo],
  generators: [timestamp_type: :utc_datetime]

config :phoenix_liveview_demo, PhoenixLiveviewDemoWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [html: PhoenixLiveviewDemoWeb.ErrorHTML, json: PhoenixLiveviewDemoWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: PhoenixLiveviewDemo.PubSub,
  live_view: [signing_salt: "your-secret-salt"]

config :phoenix_liveview_demo, PhoenixLiveviewDemo.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "phoenix_liveview_demo_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "3.3.0",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
