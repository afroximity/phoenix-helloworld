defmodule PhoenixLiveviewDemoWeb.RestaurantDashboardLive do
  use PhoenixLiveviewDemoWeb, :live_view
  alias Phoenix.PubSub

  def mount(_params, _session, socket) do
    if connected?(socket) do
      PubSub.subscribe(PhoenixLiveviewDemo.PubSub, "restaurant_metrics")
    end

    {:ok, assign(socket,
      restaurant_data: %{
        orders_per_hour: 45,
        revenue_today: 2847.50,
        avg_order_value: 28.75,
        customer_satisfaction: 4.7,
        wait_time_minutes: 12,
        table_occupancy: 78,
        staff_on_duty: 8,
        kitchen_efficiency: 92
      },
      hourly_orders: generate_hourly_data(),
      revenue_trend: generate_revenue_trend(),
      popular_items: [
        %{name: "Margherita Pizza", orders: 23, revenue: 345.00},
        %{name: "Caesar Salad", orders: 18, revenue: 234.00},
        %{name: "Grilled Salmon", orders: 15, revenue: 450.00},
        %{name: "Pasta Carbonara", orders: 12, revenue: 180.00}
      ],
      page_title: "Restaurant Dashboard - Branch #1"
    )}
  end

  def handle_info({:restaurant_update, data}, socket) do
    {:noreply, assign(socket, :restaurant_data, data)}
  end

  defp generate_hourly_data do
    for hour <- 9..21 do
      %{
        hour: "#{hour}:00",
        orders: :rand.uniform(30) + 20,
        revenue: (:rand.uniform() * 800 + 400) |> Float.round(2)
      }
    end
  end

  defp generate_revenue_trend do
    for day <- 1..7 do
      %{
        day: "Day #{day}",
        revenue: (:rand.uniform() * 2000 + 1500) |> Float.round(2)
      }
    end
  end

  # Helper function to safely format numbers
  defp format_currency(value) when is_float(value) do
    "$#{:erlang.float_to_binary(value, decimals: 0)}"
  end
  defp format_currency(value) when is_integer(value) do
    "$#{value}"
  end

  defp format_decimal(value) when is_float(value) do
    :erlang.float_to_binary(value, decimals: 2)
  end
  defp format_decimal(value) when is_integer(value) do
    "#{value}.00"
  end

  defp format_rating(value) when is_float(value) do
    :erlang.float_to_binary(value, decimals: 1)
  end
  defp format_rating(value) when is_integer(value) do
    "#{value}.0"
  end

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gradient-to-br from-orange-50 to-red-50">
      <!-- Header -->
      <div class="bg-white shadow-sm border-b border-orange-100">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div class="flex justify-between items-center py-6">
            <div class="flex items-center space-x-4">
              <div class="w-12 h-12 bg-gradient-to-r from-orange-500 to-red-500 rounded-xl flex items-center justify-center">
                <span class="text-white font-bold text-xl">🍕</span>
              </div>
              <div>
                <h1 class="text-2xl font-bold text-gray-900">Bella Vista Restaurant</h1>
                <p class="text-sm text-gray-600">Downtown Branch • Live Dashboard</p>
              </div>
            </div>
            <div class="flex items-center space-x-4">
              <div class="flex items-center space-x-2">
                <div class="w-3 h-3 bg-green-500 rounded-full animate-pulse"></div>
                <span class="text-sm text-gray-600">Live</span>
              </div>
              <div class="text-right">
                <div class="text-sm text-gray-600">Today</div>
                <div class="text-lg font-semibold text-gray-900">
                  <%= Date.utc_today() |> Calendar.strftime("%B %d, %Y") %>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <!-- Key Metrics -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <.restaurant_metric_card 
            title="Orders Today" 
            value={"#{@restaurant_data.orders_per_hour * 12}"}
            subtitle={"#{@restaurant_data.orders_per_hour}/hour avg"}
            icon="📊"
            color="blue"
            trend="+12%"
          />
          
          <.restaurant_metric_card 
            title="Revenue Today" 
            value={format_currency(@restaurant_data.revenue_today)}
            subtitle={"$#{format_decimal(@restaurant_data.avg_order_value)} avg order"}
            icon="💰"
            color="green"
            trend="+8%"
          />
          
          <.restaurant_metric_card 
            title="Customer Rating" 
            value={"#{format_rating(@restaurant_data.customer_satisfaction)}/5.0"}
            subtitle="Based on 47 reviews"
            icon="⭐"
            color="yellow"
            trend="+0.2"
          />
          
          <.restaurant_metric_card 
            title="Wait Time" 
            value={"#{@restaurant_data.wait_time_minutes} min"}
            subtitle={"#{@restaurant_data.table_occupancy}% tables occupied"}
            icon="⏱️"
            color="purple"
            trend="-3 min"
          />
        </div>

        <!-- Charts Row -->
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
          <!-- Orders Chart -->
          <div class="bg-white rounded-2xl shadow-lg p-6">
            <div class="flex items-center justify-between mb-6">
              <h3 class="text-lg font-semibold text-gray-900">Orders by Hour</h3>
              <div class="flex items-center space-x-2">
                <div class="w-3 h-3 bg-blue-500 rounded-full"></div>
                <span class="text-sm text-gray-600">Today</span>
              </div>
            </div>
            <div class="h-64">
              <.simple_bar_chart data={@hourly_orders} />
            </div>
          </div>

          <!-- Revenue Trend -->
          <div class="bg-white rounded-2xl shadow-lg p-6">
            <div class="flex items-center justify-between mb-6">
              <h3 class="text-lg font-semibold text-gray-900">Revenue Trend</h3>
              <div class="flex items-center space-x-2">
                <div class="w-3 h-3 bg-green-500 rounded-full"></div>
                <span class="text-sm text-gray-600">Last 7 days</span>
              </div>
            </div>
            <div class="h-64">
              <.simple_line_chart data={@revenue_trend} />
            </div>
          </div>
        </div>

        <!-- Bottom Row -->
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <!-- Popular Items -->
          <div class="lg:col-span-2 bg-white rounded-2xl shadow-lg p-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-6">Popular Items Today</h3>
            <div class="space-y-4">
              <%= for {item, index} <- Enum.with_index(@popular_items) do %>
                <div class="flex items-center justify-between p-4 bg-gray-50 rounded-xl">
                  <div class="flex items-center space-x-4">
                    <div class="w-8 h-8 bg-gradient-to-r from-orange-400 to-red-400 rounded-lg flex items-center justify-center text-white font-bold text-sm">
                      <%= index + 1 %>
                    </div>
                    <div>
                      <div class="font-medium text-gray-900"><%= item.name %></div>
                      <div class="text-sm text-gray-600"><%= item.orders %> orders</div>
                    </div>
                  </div>
                  <div class="text-right">
                    <div class="font-semibold text-gray-900">$<%= :erlang.float_to_binary(item.revenue, decimals: 0) %></div>
                    <div class="text-sm text-gray-600">revenue</div>
                  </div>
                </div>
              <% end %>
            </div>
          </div>

          <!-- Staff & Operations -->
          <div class="bg-white rounded-2xl shadow-lg p-6">
            <h3 class="text-lg font-semibold text-gray-900 mb-6">Operations</h3>
            <div class="space-y-6">
              <div>
                <div class="flex justify-between items-center mb-2">
                  <span class="text-sm font-medium text-gray-700">Kitchen Efficiency</span>
                  <span class="text-sm font-semibold text-gray-900"><%= @restaurant_data.kitchen_efficiency %>%</span>
                </div>
                <div class="w-full bg-gray-200 rounded-full h-2">
                  <div class="bg-green-500 h-2 rounded-full" style={"width: #{@restaurant_data.kitchen_efficiency}%"}></div>
                </div>
              </div>
              
              <div>
                <div class="flex justify-between items-center mb-2">
                  <span class="text-sm font-medium text-gray-700">Table Occupancy</span>
                  <span class="text-sm font-semibold text-gray-900"><%= @restaurant_data.table_occupancy %>%</span>
                </div>
                <div class="w-full bg-gray-200 rounded-full h-2">
                  <div class="bg-blue-500 h-2 rounded-full" style={"width: #{@restaurant_data.table_occupancy}%"}></div>
                </div>
              </div>

              <div class="pt-4 border-t border-gray-200">
                <div class="flex items-center justify-between">
                  <span class="text-sm font-medium text-gray-700">Staff on Duty</span>
                  <span class="text-lg font-semibold text-gray-900"><%= @restaurant_data.staff_on_duty %></span>
                </div>
              </div>

              <div class="flex items-center justify-between">
                <span class="text-sm font-medium text-gray-700">Avg Wait Time</span>
                <span class="text-lg font-semibold text-gray-900"><%= @restaurant_data.wait_time_minutes %> min</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Navigation -->
        <div class="mt-8 flex justify-center space-x-4">
          <.link navigate={~p"/performance"} class="px-6 py-3 bg-white text-gray-700 rounded-xl shadow-md hover:shadow-lg transition-shadow">
            Performance Monitor
          </.link>
          <.link navigate={~p"/load-test"} class="px-6 py-3 bg-gradient-to-r from-orange-500 to-red-500 text-white rounded-xl shadow-md hover:shadow-lg transition-shadow">
            Load Testing
          </.link>
        </div>
      </div>
    </div>
    """
  end

  # Restaurant-specific metric card component
  attr :title, :string, required: true
  attr :value, :string, required: true
  attr :subtitle, :string, required: true
  attr :icon, :string, required: true
  attr :color, :string, default: "blue"
  attr :trend, :string, default: nil

  def restaurant_metric_card(assigns) do
    ~H"""
    <div class="bg-white rounded-2xl shadow-lg p-6 hover:shadow-xl transition-shadow">
      <div class="flex items-center justify-between mb-4">
        <div class="text-2xl"><%= @icon %></div>
        <div :if={@trend} class="text-sm font-medium text-green-600 bg-green-50 px-2 py-1 rounded-full">
          <%= @trend %>
        </div>
      </div>
      <div class="mb-2">
        <div class="text-2xl font-bold text-gray-900"><%= @value %></div>
        <div class="text-sm font-medium text-gray-600"><%= @title %></div>
      </div>
      <div class="text-xs text-gray-500"><%= @subtitle %></div>
    </div>
    """
  end

  # Simple bar chart component
  attr :data, :list, required: true

  def simple_bar_chart(assigns) do
    max_value = Enum.max_by(assigns.data, & &1.orders).orders
    
    assigns = assign(assigns, :max_value, max_value)
    
    ~H"""
    <div class="flex items-end justify-between h-full space-x-1">
      <%= for item <- @data do %>
        <div class="flex flex-col items-center flex-1">
          <div class="w-full bg-blue-500 rounded-t-sm hover:bg-blue-600 transition-colors" 
               style={"height: #{(item.orders / @max_value * 100)}%"}
               title={"#{item.hour}: #{item.orders} orders"}>
          </div>
          <div class="text-xs text-gray-600 mt-2 transform -rotate-45 origin-top-left">
            <%= String.slice(item.hour, 0..4) %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  # Simple line chart component (using CSS for simplicity)
  attr :data, :list, required: true

  def simple_line_chart(assigns) do
    max_value = Enum.max_by(assigns.data, & &1.revenue).revenue
    
    assigns = assign(assigns, :max_value, max_value)
    
    ~H"""
    <div class="relative h-full">
      <div class="flex items-end justify-between h-full">
        <%= for {item, index} <- Enum.with_index(@data) do %>
          <div class="flex flex-col items-center flex-1 relative">
            <div class="w-2 h-2 bg-green-500 rounded-full absolute" 
                 style={"bottom: #{(item.revenue / @max_value * 80)}%"}
                 title={"#{item.day}: $#{item.revenue}"}>
            </div>
            <div class="text-xs text-gray-600 absolute -bottom-6">
              D<%= index + 1 %>
            </div>
          </div>
        <% end %>
      </div>
      <!-- Connect the dots with a line using CSS -->
      <svg class="absolute inset-0 w-full h-full pointer-events-none">
        <polyline 
          points={
            @data 
            |> Enum.with_index() 
            |> Enum.map(fn {item, index} -> 
              x = (index / (length(@data) - 1)) * 100
              y = 100 - (item.revenue / @max_value * 80)
              "#{x}%,#{y}%"
            end)
            |> Enum.join(" ")
          }
          fill="none" 
          stroke="#10b981" 
          stroke-width="2"
        />
      </svg>
    </div>
    """
  end
end
