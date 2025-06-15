defmodule PhoenixLiveviewDemo.LoadGenerator do
  use GenServer
  alias Phoenix.PubSub

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{load_level: :low, active: false}, name: __MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def set_load_level(level) when level in [:low, :medium, :high, :extreme] do
    GenServer.cast(__MODULE__, {:set_load_level, level})
  end

  def toggle_load do
    GenServer.cast(__MODULE__, :toggle_load)
  end

  def handle_cast({:set_load_level, level}, state) do
    new_state = %{state | load_level: level}
    if state.active, do: schedule_load_generation(new_state)
    {:noreply, new_state}
  end

  def handle_cast(:toggle_load, state) do
    new_state = %{state | active: !state.active}
    
    if new_state.active do
      schedule_load_generation(new_state)
    end
    
    PubSub.broadcast(PhoenixLiveviewDemo.PubSub, "load_status", {:load_status, new_state.active, new_state.load_level})
    {:noreply, new_state}
  end

  def handle_info(:generate_load, state) do
    if state.active do
      generate_load_burst(state.load_level)
      schedule_load_generation(state)
    end
    {:noreply, state}
  end

  defp schedule_load_generation(state) do
    interval = case state.load_level do
      :low -> 2000
      :medium -> 1000
      :high -> 500
      :extreme -> 100
    end
    
    Process.send_after(self(), :generate_load, interval)
  end

  defp generate_load_burst(level) do
    burst_size = case level do
      :low -> 10
      :medium -> 50
      :high -> 200
      :extreme -> 1000
    end

    data = for i <- 1..burst_size do
      %{
        id: i,
        value: :rand.uniform(1000),
        timestamp: DateTime.utc_now(),
        load_level: level
      }
    end

    PubSub.broadcast(PhoenixLiveviewDemo.PubSub, "load_data", {:load_burst, data})
  end
end
