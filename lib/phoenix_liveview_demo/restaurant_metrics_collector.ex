defmodule PhoenixLiveviewDemo.RestaurantMetricsCollector do
  use GenServer
  alias Phoenix.PubSub

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    schedule_update()
    {:ok, state}
  end

  def handle_info(:update_restaurant_data, state) do
    # Simulate realistic restaurant data changes - all as floats
    restaurant_data = %{
      orders_per_hour: :rand.uniform(20) + 35,  # 35-55 orders/hour (integer is fine)
      revenue_today: (:rand.uniform() * 1000 + 2000) |> Float.round(2),  # $2000-3000 (float)
      avg_order_value: (:rand.uniform() * 15 + 20) |> Float.round(2),  # $20-35 (float)
      customer_satisfaction: (:rand.uniform() * 1 + 4.0) |> Float.round(1),  # 4.0-5.0 (float)
      wait_time_minutes: :rand.uniform(15) + 5,  # 5-20 minutes (integer is fine)
      table_occupancy: :rand.uniform(40) + 50,  # 50-90% (integer is fine)
      staff_on_duty: :rand.uniform(4) + 6,  # 6-10 staff (integer is fine)
      kitchen_efficiency: :rand.uniform(20) + 80  # 80-100% (integer is fine)
    }

    PubSub.broadcast(PhoenixLiveviewDemo.PubSub, "restaurant_metrics", {:restaurant_update, restaurant_data})
    
    schedule_update()
    {:noreply, state}
  end

  defp schedule_update do
    Process.send_after(self(), :update_restaurant_data, 3000)  # Update every 3 seconds
  end
end
