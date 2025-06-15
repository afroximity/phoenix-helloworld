defmodule PhoenixLiveviewDemoWeb.DashboardLive do
  use PhoenixLiveviewDemoWeb, :live_view
  alias Phoenix.PubSub

  def mount(_params, _session, socket) do
    if connected?(socket) do
      PubSub.subscribe(PhoenixLiveviewDemo.PubSub, "metrics")
    end

    {:ok, assign(socket, 
      metrics: %{
        cpu_usage: 0.0,
        memory_usage: 0.0,
        active_connections: 0,
        response_time: 0.0,
        throughput: 0.0
      },
      page_title: "Phoenix LiveView Performance Demo"
    )}
  end

  def handle_info({:new_metrics, metrics}, socket) do
    {:noreply, assign(socket, :metrics, metrics)}
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-100">
      <div class="py-10">
        <header>
          <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <h1 class="text-3xl font-bold leading-tight text-gray-900">
              Phoenix LiveView Performance Demo
            </h1>
            <p class="mt-2 text-sm text-gray-600">
              Real-time metrics demonstrating diff-based rendering performance
            </p>
          </div>
        </header>
        
        <main>
          <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
            <div class="px-4 py-8 sm:px-0">
              <div class="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
                <.metric_card 
                  title="CPU Usage" 
                  value={"#{:erlang.float_to_binary(@metrics.cpu_usage, decimals: 1)}%"}
                  color="red"
                />
                
                <.metric_card 
                  title="Memory Usage" 
                  value={"#{:erlang.float_to_binary(@metrics.memory_usage, decimals: 1)} MB"}
                  color="yellow"
                />
                
                <.metric_card 
                  title="Active Connections" 
                  value={"#{@metrics.active_connections}"}
                  color="green"
                />
                
                <.metric_card 
                  title="Response Time" 
                  value={"#{:erlang.float_to_binary(@metrics.response_time, decimals: 1)}ms"}
                  color="blue"
                />
                
                <.metric_card 
                  title="Throughput" 
                  value={"#{:erlang.float_to_binary(@metrics.throughput, decimals: 0)} req/s"}
                  color="purple"
                />
                
                <div class="bg-white overflow-hidden shadow rounded-lg">
                  <div class="p-5">
                    <h3 class="text-lg font-medium text-gray-900">Navigation</h3>
                    <div class="mt-4 space-y-2">
                      <.link navigate={~p"/performance"} class="block text-blue-600 hover:text-blue-800">
                        Performance Monitor →
                      </.link>
                      <.link navigate={~p"/load-test"} class="block text-blue-600 hover:text-blue-800">
                        Load Testing →
                      </.link>
                    </div>
                  </div>
                </div>
              </div>
              
              <div class="mt-8">
                <.card>
                  <h2 class="text-xl font-semibold mb-4">About This Demo</h2>
                  <p class="text-gray-600 mb-4">
                    This Phoenix LiveView application demonstrates the power of diff-based rendering. 
                    The metrics above update in real-time, but only the changed values are sent to your browser.
                  </p>
                  <ul class="list-disc list-inside text-gray-600 space-y-1">
                    <li>Metrics update every second via WebSocket</li>
                    <li>Only changed DOM elements are updated</li>
                    <li>No full page reloads or manual JavaScript required</li>
                    <li>Efficient bandwidth usage through minimal diffs</li>
                  </ul>
                </.card>
              </div>
            </div>
          </div>
        </main>
      </div>
    </div>
    """
  end
end
