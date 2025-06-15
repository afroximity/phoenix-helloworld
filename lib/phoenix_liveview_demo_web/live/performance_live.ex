defmodule PhoenixLiveviewDemoWeb.PerformanceLive do
  use PhoenixLiveviewDemoWeb, :live_view
  alias Phoenix.PubSub

  def mount(_params, _session, socket) do
    if connected?(socket) do
      PubSub.subscribe(PhoenixLiveviewDemo.PubSub, "metrics")
    end

    {:ok, assign(socket,
      metrics_history: [],
      current_metrics: %{
        cpu_usage: 0.0,
        memory_usage: 0.0,
        active_connections: 0,
        response_time: 0.0,
        throughput: 0.0
      },
      page_title: "Performance Monitor"
    )}
  end

  def handle_info({:new_metrics, metrics}, socket) do
    new_history = [metrics | socket.assigns.metrics_history]
                  |> Enum.take(50)  # Keep last 50 data points

    {:noreply, assign(socket, 
      current_metrics: metrics,
      metrics_history: new_history
    )}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-100">
      <div class="py-10">
        <header>
          <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex justify-between items-center">
              <div>
                <h1 class="text-3xl font-bold leading-tight text-gray-900">
                  Performance Monitor
                </h1>
                <p class="mt-2 text-sm text-gray-600">
                  Real-time performance metrics with historical data
                </p>
              </div>
              <.link navigate={~p"/"} class="text-blue-600 hover:text-blue-800">
                ← Back to Dashboard
              </.link>
            </div>
          </div>
        </header>
        
        <main>
          <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            <div class="px-4 py-8 sm:px-0">
              <!-- Current Metrics -->
              <div class="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-5 mb-8">
                <.metric_card 
                  title="CPU Usage" 
                  value={"#{:erlang.float_to_binary(@current_metrics.cpu_usage, decimals: 1)}%"}
                  color="red"
                />
                
                <.metric_card 
                  title="Memory Usage" 
                  value={"#{:erlang.float_to_binary(@current_metrics.memory_usage, decimals: 1)} MB"}
                  color="yellow"
                />
                
                <.metric_card 
                  title="Connections" 
                  value={"#{@current_metrics.active_connections}"}
                  color="green"
                />
                
                <.metric_card 
                  title="Response Time" 
                  value={"#{:erlang.float_to_binary(@current_metrics.response_time, decimals: 1)}ms"}
                  color="blue"
                />
                
                <.metric_card 
                  title="Throughput" 
                  value={"#{:erlang.float_to_binary(@current_metrics.throughput, decimals: 0)} req/s"}
                  color="purple"
                />
              </div>

              <!-- Historical Data Table -->
              <.card>
                <h2 class="text-xl font-semibold mb-4">Historical Metrics</h2>
                <div class="overflow-x-auto">
                  <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                      <tr>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                          Time
                        </th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                          CPU %
                        </th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                          Memory MB
                        </th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                          Connections
                        </th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                          Response ms
                        </th>
                        <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                          Throughput
                        </th>
                      </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
                      <%= for {metric, index} <- Enum.with_index(@metrics_history) do %>
                        <tr class={if rem(index, 2) == 0, do: "bg-white", else: "bg-gray-50"}>
                          <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                            <%= DateTime.to_time(DateTime.utc_now()) |> Time.to_string() %>
                          </td>
                          <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                            <%= :erlang.float_to_binary(metric.cpu_usage, decimals: 1) %>%
                          </td>
                          <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                            <%= :erlang.float_to_binary(metric.memory_usage, decimals: 1) %>
                          </td>
                          <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                            <%= metric.active_connections %>
                          </td>
                          <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                            <%= :erlang.float_to_binary(metric.response_time, decimals: 1) %>
                          </td>
                          <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                            <%= :erlang.float_to_binary(metric.throughput, decimals: 0) %>
                          </td>
                        </tr>
                      <% end %>
                    </tbody>
                  </table>
                </div>
                
                <div :if={Enum.empty?(@metrics_history)} class="text-center py-8 text-gray-500">
                  Waiting for metrics data...
                </div>
              </.card>
            </div>
          </div>
        </main>
      </div>
    </div>
    """
  end
end
