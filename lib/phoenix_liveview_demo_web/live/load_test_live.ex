defmodule PhoenixLiveviewDemoWeb.LoadTestLive do
  use PhoenixLiveviewDemoWeb, :live_view
  alias Phoenix.PubSub
  alias PhoenixLiveviewDemo.LoadGenerator

  def mount(_params, _session, socket) do
    if connected?(socket) do
      PubSub.subscribe(PhoenixLiveviewDemo.PubSub, "load_data")
      PubSub.subscribe(PhoenixLiveviewDemo.PubSub, "load_status")
    end

    {:ok, assign(socket,
      load_data: [],
      load_active: false,
      load_level: :low,
      total_items: 0,
      page_title: "Load Testing"
    )}
  end

  def handle_event("toggle_load", _params, socket) do
    LoadGenerator.toggle_load()
    {:noreply, socket}
  end

  def handle_event("set_load_level", %{"level" => level}, socket) do
    level_atom = String.to_atom(level)
    LoadGenerator.set_load_level(level_atom)
    {:noreply, assign(socket, :load_level, level_atom)}
  end

  def handle_event("clear_data", _params, socket) do
    {:noreply, assign(socket, load_data: [], total_items: 0)}
  end

  def handle_info({:load_burst, data}, socket) do
    new_data = (data ++ socket.assigns.load_data)
               |> Enum.take(1000)  # Keep last 1000 items for performance

    {:noreply, assign(socket, 
      load_data: new_data,
      total_items: socket.assigns.total_items + length(data)
    )}
  end

  def handle_info({:load_status, active, level}, socket) do
    {:noreply, assign(socket, load_active: active, load_level: level)}
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
                  Load Testing Dashboard
                </h1>
                <p class="mt-2 text-sm text-gray-600">
                  Test LiveView performance under different load conditions
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
              <!-- Controls -->
              <.card class="mb-8">
                <h2 class="text-xl font-semibold mb-4">Load Controls</h2>
                <div class="flex flex-wrap gap-4 items-center">
                  <button 
                    phx-click="toggle_load"
                    class={[
                      "px-4 py-2 rounded-md font-medium",
                      if(@load_active, do: "bg-red-600 text-white", else: "bg-green-600 text-white")
                    ]}
                  >
                    <%= if @load_active, do: "Stop Load", else: "Start Load" %>
                  </button>
                  
                  <div class="flex gap-2">
                    <%= for level <- [:low, :medium, :high, :extreme] do %>
                      <button 
                        phx-click="set_load_level" 
                        phx-value-level={level}
                        class={[
                          "px-3 py-1 rounded text-sm font-medium",
                          if(@load_level == level, 
                            do: "bg-blue-600 text-white", 
                            else: "bg-gray-200 text-gray-700 hover:bg-gray-300"
                          )
                        ]}
                      >
                        <%= String.capitalize(to_string(level)) %>
                      </button>
                    <% end %>
                  </div>
                  
                  <button 
                    phx-click="clear_data"
                    class="px-4 py-2 bg-gray-600 text-white rounded-md font-medium hover:bg-gray-700"
                  >
                    Clear Data
                  </button>
                </div>
                
                <div class="mt-4 text-sm text-gray-600">
                  <p><strong>Status:</strong> <%= if @load_active, do: "Active", else: "Inactive" %></p>
                  <p><strong>Level:</strong> <%= String.capitalize(to_string(@load_level)) %></p>
                  <p><strong>Total Items Generated:</strong> <%= @total_items %></p>
                  <p><strong>Items Displayed:</strong> <%= length(@load_data) %></p>
                </div>
              </.card>

              <!-- Load Level Info -->
              <.card class="mb-8">
                <h2 class="text-xl font-semibold mb-4">Load Level Information</h2>
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                  <div class="p-4 bg-green-50 rounded-lg">
                    <h3 class="font-semibold text-green-800">Low</h3>
                    <p class="text-sm text-green-600">10 items every 2 seconds</p>
                  </div>
                  <div class="p-4 bg-yellow-50 rounded-lg">
                    <h3 class="font-semibold text-yellow-800">Medium</h3>
                    <p class="text-sm text-yellow-600">50 items every 1 second</p>
                  </div>
                  <div class="p-4 bg-orange-50 rounded-lg">
                    <h3 class="font-semibold text-orange-800">High</h3>
                    <p class="text-sm text-orange-600">200 items every 0.5 seconds</p>
                  </div>
                  <div class="p-4 bg-red-50 rounded-lg">
                    <h3 class="font-semibold text-red-800">Extreme</h3>
                    <p class="text-sm text-red-600">1000 items every 0.1 seconds</p>
                  </div>
                </div>
              </.card>

              <!-- Live Data Display -->
              <.card>
                <h2 class="text-xl font-semibold mb-4">Live Data Stream</h2>
                <div class="max-h-96 overflow-y-auto">
                  <div :if={Enum.empty?(@load_data)} class="text-center py-8 text-gray-500">
                    No data yet. Start the load generator to see real-time updates.
                  </div>
                  
                  <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-2">
                    <%= for item <- @load_data do %>
                      <div class={[
                        "p-3 rounded border text-sm",
                        case item.load_level do
                          :low -> "bg-green-50 border-green-200"
                          :medium -> "bg-yellow-50 border-yellow-200"
                          :high -> "bg-orange-50 border-orange-200"
                          :extreme -> "bg-red-50 border-red-200"
                        end
                      ]}>
                        <div class="font-mono text-xs">ID: <%= item.id %></div>
                        <div class="font-semibold">Value: <%= item.value %></div>
                        <div class="text-xs text-gray-500">
                          <%= String.capitalize(to_string(item.load_level)) %>
                        </div>
                      </div>
                    <% end %>
                  </div>
                </div>
              </.card>
              
              <div class="mt-8">
                <.card>
                  <h2 class="text-xl font-semibold mb-4">Performance Notes</h2>
                  <ul class="list-disc list-inside text-gray-600 space-y-2">
                    <li>Watch your browser's developer tools Network tab to see minimal data transfer</li>
                    <li>Only new items and changed elements are sent over the WebSocket</li>
                    <li>The DOM efficiently updates only the parts that change</li>
                    <li>Try different load levels to see how LiveView handles high-frequency updates</li>
                    <li>Notice how the UI remains responsive even under extreme load</li>
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
