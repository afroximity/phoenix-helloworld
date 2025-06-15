import Config

config :phoenix_liveview_demo, PhoenixLiveviewDemoWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "your-very-long-secret-key-base-here-make-it-at-least-64-characters-long",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:default, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:default, ~w(--watch)]}
  ]

config :phoenix_liveview_demo, PhoenixLiveviewDemoWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/phoenix_liveview_demo_web/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

# Try different database configurations
config :phoenix_liveview_demo, PhoenixLiveviewDemo.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "phoenix_liveview_demo_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10,
  port: 5432

# If your PostgreSQL is running on a different port, change it here:
# port: 5433

# If you have different credentials, update them:
# username: "your_username",
# password: "your_password",

# If PostgreSQL is running without password authentication:
# password: "",

config :phoenix_liveview_demo, dev_routes: true

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime
