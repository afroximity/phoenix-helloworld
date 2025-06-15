defmodule PhoenixLiveviewDemoWeb.Router do
  use PhoenixLiveviewDemoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PhoenixLiveviewDemoWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PhoenixLiveviewDemoWeb do
    pipe_through :browser

    live "/", DashboardLive
    live "/performance", PerformanceLive
    live "/load-test", LoadTestLive
  end

  if Application.compile_env(:phoenix_liveview_demo, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PhoenixLiveviewDemoWeb.Telemetry
    end
  end
end
