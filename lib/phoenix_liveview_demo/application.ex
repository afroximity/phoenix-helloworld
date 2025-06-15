defmodule PhoenixLiveviewDemo.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PhoenixLiveviewDemo.Repo,
      {DNSCluster, query: Application.get_env(:phoenix_liveview_demo, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PhoenixLiveviewDemo.PubSub},
      {Finch, name: PhoenixLiveviewDemo.Finch},
      PhoenixLiveviewDemoWeb.Endpoint,
      PhoenixLiveviewDemo.MetricsCollector,
      PhoenixLiveviewDemo.LoadGenerator,
      PhoenixLiveviewDemo.RestaurantMetricsCollector
    ]

    opts = [strategy: :one_for_one, name: PhoenixLiveviewDemo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    PhoenixLiveviewDemoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
