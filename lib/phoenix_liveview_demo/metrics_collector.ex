defmodule PhoenixLiveviewDemo.MetricsCollector do
  use GenServer
  alias PhoenixLiveviewDemo.{Repo, Metrics}
  alias Phoenix.PubSub

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    schedule_collection()
    {:ok, state}
  end

  def handle_info(:collect_metrics, state) do
    metrics = collect_system_metrics()
    
    # Save to database
    %Metrics{}
    |> Metrics.changeset(metrics)
    |> Repo.insert()

    # Broadcast to LiveView
    PubSub.broadcast(PhoenixLiveviewDemo.PubSub, "metrics", {:new_metrics, metrics})
    
    schedule_collection()
    {:noreply, state}
  end

  defp schedule_collection do
    Process.send_after(self(), :collect_metrics, 1000)
  end

  defp collect_system_metrics do
    memory_info = :erlang.memory()
    process_count = :erlang.system_info(:process_count)
    
    %{
      cpu_usage: :rand.uniform() * 100,
      memory_usage: memory_info[:total] / (1024 * 1024),
      active_connections: process_count,
      response_time: :rand.uniform() * 50 + 10,
      throughput: :rand.uniform() * 1000 + 500
    }
  end
end
